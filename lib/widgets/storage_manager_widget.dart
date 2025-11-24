import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../services/storage_service.dart';

/// Reusable widget for hybrid storage manager UI.
class StorageManagerWidget extends StatefulWidget {
  const StorageManagerWidget({super.key});

  @override
  State<StorageManagerWidget> createState() => _StorageManagerWidgetState();
}

class _StorageManagerWidgetState extends State<StorageManagerWidget> {
  final _service = StorageService();
  List<dynamic> _files = [];
  String? _error;
  PlatformFile? _selectedFile;
  Uint8List? _selectedBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  /// Load file inventory from backend
  Future<void> _loadFiles() async {
    try {
      final files = await _service.listFiles();
      if (!mounted) return;
      setState(() {
        _files = files;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load files: $e';
      });
    }
  }

  /// Pick a file from the local device
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final data = await _resolveFileBytes(file);

      if (data == null || data.isEmpty) {
        setState(() {
          _error =
              'Unable to access file bytes. Please try again with a smaller file.';
        });
        return;
      }

      setState(() {
        _selectedFile = file;
        _selectedBytes = data;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'File selection failed: $e';
      });
    }
  }

  /// Upload the selected file to backend storage
  Future<void> _uploadFile() async {
    if (_selectedFile == null || _selectedBytes == null) {
      setState(() {
        _error = 'Please select a file to upload';
      });
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final file = _selectedFile!;
      final bytes = _selectedBytes!;
      final header = bytes.length > 16 ? bytes.sublist(0, 16) : bytes;
      final mime = lookupMimeType(file.name, headerBytes: header);

      await _service.uploadFileFromBytes(file.name, bytes, mimeType: mime);

      if (!mounted) return;
      setState(() {
        _selectedFile = null;
        _selectedBytes = null;
        _error = null;
      });

      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Upload failed: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// Delete a file by backend identifier
  Future<void> _deleteFile(int id) async {
    try {
      await _service.deleteFile(id);
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Delete failed: $e';
      });
    }
  }

  /// Resolve the byte payload for the selected file
  Future<Uint8List?> _resolveFileBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes;
    }

    final stream = file.readStream;
    if (stream == null) {
      return null;
    }

    final accumulator = BytesBuilder();
    await for (final chunk in stream) {
      accumulator.add(chunk);
    }
    return accumulator.takeBytes();
  }

  /// Format file size display helper
  String _formatBytes(int? size) {
    if (size == null || size <= 0) {
      return '0 B';
    }

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = size.toDouble();
    var index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    final precision = index == 0 ? 0 : 1;
    return '${value.toStringAsFixed(precision)} ${units[index]}';
  }

  /// Build subtitle widget with metadata and preview
  Widget _buildFileSubtitle(Map<String, dynamic> file) {
    final parsedSize = file['size'] is int
        ? file['size'] as int
        : int.tryParse(file['size']?.toString() ?? '');
    final metadataParts = <String>[];

    if (file['mimeType'] != null) {
      metadataParts.add(file['mimeType'].toString());
    }
    if (parsedSize != null) {
      metadataParts.add(_formatBytes(parsedSize));
    }
    if (file['uploadedAt'] != null) {
      metadataParts.add(file['uploadedAt'].toString());
    }

    final metadata = metadataParts.join(' • ');
    final previewText = (file['preview'] ?? file['content'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (metadata.isNotEmpty)
          Text(
            metadata,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        if (previewText.isNotEmpty)
          Text(
            previewText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload File',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isUploading ? null : _pickFile,
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Choose File'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: _selectedFile == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'No file selected',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Select a document, image, or any file from your device to upload.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFile!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedFile!.extension?.toUpperCase() ?? 'FILE'} • ${_formatBytes(_selectedBytes?.length ?? _selectedFile!.size)}',
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: Text(
                          _isUploading ? 'Uploading...' : 'Upload File',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _selectedFile == null || _isUploading
                            ? null
                            : _uploadFile,
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Files',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _files.isEmpty
                  ? Center(
                      child: Text(
                        'No files uploaded yet.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade200,
                              child: const Icon(
                                Icons.insert_drive_file,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              file['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: _buildFileSubtitle(file),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteFile(file['id']),
                              tooltip: 'Delete',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
