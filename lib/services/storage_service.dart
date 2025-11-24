import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for encrypted local and cloud storage management.
class StorageService {
  /// Get platform-aware base URL
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      return 'http://127.0.0.1:3000/api';
    }
  }

  /// Uploads binary file content with metadata support
  Future<Map<String, dynamic>?> uploadFileFromBytes(
    String name,
    Uint8List data, {
    String? mimeType,
  }) async {
    return _postUpload({
      'name': name,
      'contentBase64': base64Encode(data),
      'size': data.length,
      if (mimeType != null) 'mimeType': mimeType,
    });
  }

  /// Uploads plain text content (legacy support)
  Future<Map<String, dynamic>?> uploadFile(String name, String content) {
    return _postUpload({
      'name': name,
      'content': content,
      'size': content.length,
      'mimeType': 'text/plain',
    });
  }

  /// Internal helper to post payload to backend
  Future<Map<String, dynamic>?> _postUpload(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/file/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }
    final message = decoded is Map<String, dynamic>
        ? decoded['error']?.toString()
        : null;
    throw Exception(
      message ?? 'Upload failed with status ${response.statusCode}',
    );
  }

  /// Lists files from backend
  Future<List<dynamic>> listFiles() async {
    final response = await http.get(Uri.parse('$baseUrl/file/list'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  /// Deletes a file by id
  Future<bool> deleteFile(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/file/$id'));
    return response.statusCode == 200;
  }
}
