import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get user => _authService.currentUser;

  bool _loading = false;

  bool get loading => _loading;

  String? _error;

  String? get error => _error;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login(
      String email,
      String password,
      ) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Login error: $e');

      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<bool> register(
      String email,
      String password,
      ) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.register(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Register error: $e');

      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await _authService.logout();
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // LOADING
  // ============================================================

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // ============================================================
  // FIREBASE AUTH ERRORS
  // ============================================================

  String _authError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'weak-password':
        return 'Password must be at least 6 characters.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}