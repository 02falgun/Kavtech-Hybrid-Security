import 'package:flutter/material.dart';
import '../widgets/unified_dashboard_widget.dart';

/// Unified Dashboard Module
/// Displays file list, user activity, compliance score, and cloud usage.
class UnifiedDashboardModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unified Dashboard')),
      body: const UnifiedDashboardWidget(),
    );
  }
}
