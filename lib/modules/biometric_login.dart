import 'package:flutter/material.dart';
import '../widgets/biometric_login_widget.dart';

/// Biometric Login Module
/// Handles fingerprint/face ID authentication and role-based access.
class BiometricLoginModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Login')),
      body: const BiometricLoginWidget(),
    );
  }
}
