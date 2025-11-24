import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/biometric_service.dart';

/// Enhanced reusable widget for biometric login UI with professional design.
class BiometricLoginWidget extends StatefulWidget {
  const BiometricLoginWidget({super.key});

  @override
  State<BiometricLoginWidget> createState() => _BiometricLoginWidgetState();
}

class _BiometricLoginWidgetState extends State<BiometricLoginWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _biometricService = BiometricService();

  Map<String, dynamic>? _loginResult;
  String? _error;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _obscurePassword = true;
  bool _isBackendConnected = false;

  @override
  void initState() {
    super.initState();
    _checkCapabilities();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Check biometric availability and backend connectivity
  Future<void> _checkCapabilities() async {
    setState(() => _isLoading = true);

    try {
      final biometricAvailable = await _biometricService.isBiometricAvailable();
      final backendConnected = await _biometricService
          .checkBackendConnectivity();

      setState(() {
        _isBiometricAvailable = biometricAvailable;
        _isBackendConnected = backendConnected;
      });
    } catch (e) {
      setState(() => _error = 'Failed to check capabilities: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle credential-based login
  Future<void> _login() async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _error = 'Please enter both username and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _biometricService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _loginResult = result;
        _error = null;
      });

      // Ask if user wants to enable biometric login
      if (_isBiometricAvailable && result != null) {
        await _showBiometricEnableDialog();
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loginResult = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle biometric authentication
  Future<void> _loginWithBiometric() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isAuthenticated = await _biometricService
          .authenticateWithBiometric();

      if (isAuthenticated) {
        final username = await _biometricService.getBiometricUsername();
        if (username != null) {
          setState(
            () => _loginResult = {
              'message': 'Biometric authentication successful',
              'user': {'username': username},
              'role':
                  'user', // In a real app, this would come from stored session
            },
          );
        }
      } else {
        setState(() => _error = 'Biometric authentication failed');
      }
    } catch (e) {
      setState(() => _error = 'Biometric error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Show dialog to enable biometric login
  Future<void> _showBiometricEnableDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.indigo.shade600),
            const SizedBox(width: 8),
            const Text('Enable Biometric Login'),
          ],
        ),
        content: const Text(
          'Would you like to enable biometric authentication for faster login next time?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, Thanks'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _biometricService.enableBiometricLogin(
        _usernameController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric login enabled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade50,
            Colors.indigo.shade100,
            Colors.purple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildConnectionStatus(),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else ...[
                        _buildLoginForm(),
                        const SizedBox(height: 20),
                        if (_isBiometricAvailable) _buildBiometricSection(),
                      ],
                      if (_loginResult != null) _buildSuccessMessage(),
                      if (_error != null) _buildErrorMessage(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with icon and title
  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.shade200,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.security, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'KAVTECH Security',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
          Text(
            'Biometric Authentication',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Build connection status indicator
  Widget _buildConnectionStatus() {
    return FadeInLeft(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isBackendConnected
              ? Colors.green.shade50
              : Colors.red.shade50,
          border: Border.all(
            color: _isBackendConnected ? Colors.green : Colors.red,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isBackendConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isBackendConnected ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _isBackendConnected ? 'Backend Connected' : 'Backend Offline',
              style: TextStyle(
                color: _isBackendConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build login form
  Widget _buildLoginForm() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person, color: Colors.indigo.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock, color: Colors.indigo.shade600),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.indigo.shade600,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
              ),
            ),
            obscureText: _obscurePassword,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: _isBackendConnected ? _login : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Build biometric authentication section
  Widget _buildBiometricSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loginWithBiometric,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.indigo.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade100,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 48,
                    color: Colors.indigo.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Biometric Login',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build success message
  Widget _buildSuccessMessage() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Successful!',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_loginResult?['user']?['username'] != null)
                      Text(
                        'Welcome, ${_loginResult!['user']['username']}',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    if (_loginResult?['role'] != null)
                      Text(
                        'Role: ${_loginResult!['role']}',
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error message
  Widget _buildErrorMessage() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
