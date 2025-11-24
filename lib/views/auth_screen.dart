import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/biometric_service.dart';
import '../main.dart';

/// Professional authentication screen with login and registration.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.animate = true});
  final bool animate;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _biometricService = BiometricService();

  // Form controllers
  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isBackendConnected = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkInitialState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  /// Check initial state for biometric availability and backend connectivity
  Future<void> _checkInitialState() async {
    setState(() => _isLoading = true);

    try {
      // Check backend connectivity
      final isConnected = await _biometricService.checkBackendConnectivity();

      // Check biometric availability
      final isBiometricAvailable = await _biometricService
          .isBiometricAvailable();
      final isBiometricEnabled = await _biometricService
          .isBiometricLoginEnabled();

      setState(() {
        _isBackendConnected = isConnected;
        _isBiometricAvailable = isBiometricAvailable;
        _isBiometricEnabled = isBiometricEnabled;
      });

      // If user is already logged in, navigate to dashboard
      final isLoggedIn = await _biometricService.isLoggedIn();
      if (isLoggedIn && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle biometric authentication
  Future<void> _handleBiometricAuth() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAuthenticated = await _biometricService
          .authenticateWithBiometric();

      if (isAuthenticated) {
        final username = await _biometricService.getBiometricUsername();
        if (username != null && mounted) {
          setState(
            () => _successMessage = 'Biometric authentication successful!',
          );

          // Navigate to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else {
        setState(() => _errorMessage = 'Biometric authentication failed');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Biometric error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle user login
  Future<void> _handleLogin() async {
    if (!_validateLoginForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _biometricService.login(
        _loginUsernameController.text.trim(),
        _loginPasswordController.text,
      );

      if (result != null && mounted) {
        setState(() => _successMessage = 'Login successful!');

        // Ask if user wants to enable biometric login
        if (_isBiometricAvailable) {
          await _showBiometricEnableDialog();
        }

        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle user registration
  Future<void> _handleRegistration() async {
    if (!_validateRegistrationForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _biometricService.register(
        username: _registerUsernameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
      );

      if (result != null) {
        setState(() {
          _successMessage = 'Registration successful! Please login.';
          _tabController.animateTo(0); // Switch to login tab
        });

        // Clear registration form
        _registerUsernameController.clear();
        _registerEmailController.clear();
        _registerPasswordController.clear();
        _registerConfirmPasswordController.clear();
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Validate login form
  bool _validateLoginForm() {
    if (_loginUsernameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter username');
      return false;
    }
    if (_loginPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter password');
      return false;
    }
    return true;
  }

  /// Validate registration form
  bool _validateRegistrationForm() {
    if (_registerUsernameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter username');
      return false;
    }
    if (_registerEmailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter email');
      return false;
    }
    if (!_isValidEmail(_registerEmailController.text.trim())) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return false;
    }
    if (_registerPasswordController.text.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return false;
    }
    if (_registerPasswordController.text !=
        _registerConfirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return false;
    }
    return true;
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Show dialog to enable biometric login
  Future<void> _showBiometricEnableDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Login'),
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
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _biometricService.enableBiometricLogin(
        _loginUsernameController.text.trim(),
      );
      setState(() => _isBiometricEnabled = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade900,
              Colors.deepPurple.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildConnectionStatus(),
                        const SizedBox(height: 20),
                        _buildAuthCard(),
                        const SizedBox(height: 20),
                        if (_isBiometricAvailable && _isBiometricEnabled)
                          _buildBiometricButton(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Build app header with logo and title
  Widget _buildHeader() {
    final child = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.security, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          'KAVTECH',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Text(
          'Hybrid Security Suite',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
    if (!widget.animate) return child;
    return FadeInDown(
      duration: const Duration(milliseconds: 1000),
      child: child,
    );
  }

  /// Build connection status indicator
  Widget _buildConnectionStatus() {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isBackendConnected
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
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
            _isBackendConnected ? 'Connected to Server' : 'Server Offline',
            style: TextStyle(
              color: _isBackendConnected ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
    if (!widget.animate) return child;
    return FadeInUp(duration: const Duration(milliseconds: 800), child: child);
  }

  /// Build main authentication card
  Widget _buildAuthCard() {
    final child = GlassmorphicContainer(
      width: double.infinity,
      height: 500,
      borderRadius: 20,
      blur: 15,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.2)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTabBar(),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLoginForm(), _buildRegistrationForm()],
              ),
            ),
            if (_errorMessage != null) _buildErrorMessage(),
            if (_successMessage != null) _buildSuccessMessage(),
          ],
        ),
      ),
    );
    if (!widget.animate) return child;
    return FadeInUp(duration: const Duration(milliseconds: 1000), child: child);
  }

  /// Build tab bar for login/register
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Register'),
        ],
      ),
    );
  }

  /// Build login form
  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _loginUsernameController,
          label: 'Username',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _loginPasswordController,
          label: 'Password',
          icon: Icons.lock,
          obscureText: _obscureLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureLoginPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () =>
                setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          label: 'Login',
          onPressed: _isBackendConnected ? _handleLogin : null,
        ),
      ],
    );
  }

  /// Build registration form
  Widget _buildRegistrationForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _registerUsernameController,
          label: 'Username',
          icon: Icons.person,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerEmailController,
          label: 'Email',
          icon: Icons.email,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerPasswordController,
          label: 'Password',
          icon: Icons.lock,
          obscureText: _obscureRegisterPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegisterPassword
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () => setState(
              () => _obscureRegisterPassword = !_obscureRegisterPassword,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerConfirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          label: 'Register',
          onPressed: _isBackendConnected ? _handleRegistration : null,
        ),
      ],
    );
  }

  /// Build custom text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Build biometric authentication button
  Widget _buildBiometricButton() {
    final child = GestureDetector(
      onTap: _handleBiometricAuth,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: Icon(Icons.fingerprint, size: 40, color: Colors.white),
      ),
    );
    if (!widget.animate) return child;
    return FadeInUp(duration: const Duration(milliseconds: 1200), child: child);
  }

  /// Build error message
  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Build success message
  Widget _buildSuccessMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        _successMessage!,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
