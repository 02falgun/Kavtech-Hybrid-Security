import 'package:flutter/material.dart';

/// Reusable widget for compliance checker UI.
class ComplianceCheckerWidget extends StatefulWidget {
  @override
  State<ComplianceCheckerWidget> createState() =>
      _ComplianceCheckerWidgetState();
}

class _ComplianceCheckerWidgetState extends State<ComplianceCheckerWidget> {
  final _fileController = TextEditingController();
  String? _result;

  void _checkCompliance() {
    setState(() {
      // Simulate compliance check
      if (_fileController.text.isEmpty) {
        _result = 'Please enter a file name.';
      } else if (_fileController.text.toLowerCase().contains('private')) {
        _result = 'Non-compliant: Contains sensitive data.';
      } else {
        _result = 'Compliant: File meets DPDP Act rules.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 48,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Compliance Checker',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _fileController,
                    decoration: InputDecoration(
                      labelText: 'File Name',
                      prefixIcon: const Icon(Icons.insert_drive_file),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Check Compliance'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.orange.shade400,
                      ),
                      onPressed: _checkCompliance,
                    ),
                  ),
                  if (_result != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _result!,
                        style: TextStyle(
                          color: _result!.startsWith('Compliant')
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
