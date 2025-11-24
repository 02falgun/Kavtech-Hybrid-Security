import 'package:flutter/material.dart';
import '../widgets/compliance_checker_widget.dart';

/// Compliance Checker Module
/// Validates files against DPDP Act and generates audit reports.
class ComplianceCheckerModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compliance Checker')),
      body: ComplianceCheckerWidget(),
    );
  }
}
