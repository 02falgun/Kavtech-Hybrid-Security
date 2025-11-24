import 'package:flutter/material.dart';
import '../widgets/storage_manager_widget.dart';

/// Hybrid Storage Manager Module
/// Manages encrypted file storage (local/cloud) and AI-based suggestions.
class HybridStorageManagerModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hybrid Storage Manager')),
      body: const StorageManagerWidget(),
    );
  }
}
