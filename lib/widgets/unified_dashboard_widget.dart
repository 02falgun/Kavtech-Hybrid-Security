import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

/// Reusable widget for unified dashboard UI.
class UnifiedDashboardWidget extends StatefulWidget {
  const UnifiedDashboardWidget({super.key});

  @override
  State<UnifiedDashboardWidget> createState() => _UnifiedDashboardWidgetState();
}

class _UnifiedDashboardWidgetState extends State<UnifiedDashboardWidget> {
  final _service = DashboardService();
  Map<String, dynamic> _summary = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      print('Dashboard Widget: Starting to load summary...');
      final summary = await _service.getSummary();
      print('Dashboard Widget: Summary loaded successfully: $summary');
      setState(() {
        _summary = summary;
        _loading = false;
      });
      print('Dashboard Widget: Loading state set to false');
    } catch (e) {
      print('Dashboard Widget Error: $e');
      setState(() {
        _summary = {'files': [], 'roles': [], 'fileCount': 0, 'roleCount': 0};
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final files = _summary['files'] ?? [];
    final roles = _summary['roles'] ?? [];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
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
              'KAVTECH Dashboard',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
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
                        Icon(Icons.folder, color: Colors.teal.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Files',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${_summary['fileCount'] ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...files
                        .map<Widget>(
                          (f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  size: 18,
                                  color: Colors.teal.shade300,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    f['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
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
                        Icon(Icons.people, color: Colors.teal.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'User Roles',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${_summary['roleCount'] ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...roles
                        .map<Widget>(
                          (r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 18,
                                  color: Colors.teal.shade300,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    r,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
