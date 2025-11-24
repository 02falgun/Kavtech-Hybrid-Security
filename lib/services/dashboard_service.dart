import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for unified dashboard data aggregation.
class DashboardService {
  /// Get platform-aware base URL
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      return 'http://127.0.0.1:3000/api';
    }
  }

  /// Fetches dashboard summary data (files and user roles)
  Future<Map<String, dynamic>> getSummary() async {
    try {
      print('Dashboard Service: Fetching data from $baseUrl');

      // Fetch files
      final filesResp = await http.get(Uri.parse('$baseUrl/file/list'));
      print(
        'Dashboard Service: Files response status: ${filesResp.statusCode}',
      );

      // Fetch roles
      final rolesResp = await http.get(Uri.parse('$baseUrl/user/roles'));
      print(
        'Dashboard Service: Roles response status: ${rolesResp.statusCode}',
      );

      List<dynamic> files = filesResp.statusCode == 200
          ? jsonDecode(filesResp.body)
          : [];
      List<dynamic> roles = rolesResp.statusCode == 200
          ? jsonDecode(rolesResp.body)
          : [];

      print(
        'Dashboard Service: Found ${files.length} files and ${roles.length} roles',
      );

      return {
        'files': files,
        'roles': roles,
        'fileCount': files.length,
        'roleCount': roles.length,
      };
    } catch (e) {
      print('Dashboard Service Error: $e');
      // Return empty data on error to prevent infinite loading
      return {'files': [], 'roles': [], 'fileCount': 0, 'roleCount': 0};
    }
  }
}
