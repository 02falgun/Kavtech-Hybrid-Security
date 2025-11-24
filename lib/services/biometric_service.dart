import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Enhanced service for biometric authentication with backend connectivity.
class BiometricService {
  // Use different URLs for web vs mobile platforms
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      // Physical device connected over USB uses adb reverse to reach localhost
      return 'http://127.0.0.1:3000/api';
    }
  }

  String get healthUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/health';
    } else {
      // Physical device connected over USB uses adb reverse to reach localhost
      return 'http://127.0.0.1:3000/health';
    }
  }

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if backend is reachable
  Future<bool> checkBackendConnectivity() async {
    try {
      // Check network connectivity first
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Try to reach the backend health endpoint
      final response = await http
          .get(Uri.parse(healthUrl))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Backend connectivity check failed: $e');
      return false;
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      // Biometric authentication is not available on web platforms
      if (kIsWeb) {
        return false;
      }

      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Biometric availability check failed: $e');
      return false;
    }
  }

  /// Authenticate using biometric (fingerprint/face)
  Future<bool> authenticateWithBiometric() async {
    try {
      // Biometric authentication is not available on web platforms
      if (kIsWeb) {
        print('Biometric: Web platform detected, biometric auth disabled');
        return false;
      }

      // Check if device supports biometric authentication
      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) {
        print('Biometric: Device does not support biometric authentication');
        return false;
      }

      // Check if biometric authentication can be used
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        print('Biometric: Cannot check biometrics on this device');
        return false;
      }

      // Get available biometric types
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        print('Biometric: No biometric authentication methods available');
        return false;
      }

      print('Biometric: Available biometric types: $availableBiometrics');

      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access KAVTECH Security Suite',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      print('Biometric: Authentication result: $isAuthenticated');
      return isAuthenticated;
    } catch (e) {
      print('Biometric authentication failed: $e');
      return false;
    }
  }

  /// Register a new user with the backend
  Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  /// Authenticate user with backend credentials
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store user session
        await _storeUserSession(data);

        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  /// Store user session locally
  Future<void> _storeUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', jsonEncode(userData));
    await prefs.setBool('is_logged_in', true);
  }

  /// Enable biometric login for the current user
  Future<bool> enableBiometricLogin(String username) async {
    try {
      // Check if biometric authentication is available first
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print(
          'Biometric: Cannot enable - biometric authentication not available',
        );
        return false;
      }

      // Test biometric authentication once to ensure it works
      final testAuth = await authenticateWithBiometric();
      if (!testAuth) {
        print(
          'Biometric: Cannot enable - biometric authentication test failed',
        );
        return false;
      }

      // Store biometric login settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('biometric_username', username);
      await prefs.setBool('biometric_enabled', true);

      print('Biometric: Successfully enabled for user: $username');
      return true;
    } catch (e) {
      print('Enable biometric login failed: $e');
      return false;
    }
  }

  /// Get stored user session
  Future<Map<String, dynamic>?> getUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (!isLoggedIn) return null;

      final sessionString = prefs.getString('user_session');
      if (sessionString != null) {
        return jsonDecode(sessionString);
      }
      return null;
    } catch (e) {
      print('Get user session error: $e');
      return null;
    }
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  /// Get username for biometric login
  Future<String?> getBiometricUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('biometric_username');
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    await prefs.setBool('is_logged_in', false);
    // Keep biometric settings unless user explicitly disables them
  }

  /// Disable biometric login
  Future<void> disableBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('biometric_username');
    await prefs.setBool('biometric_enabled', false);
  }
}
