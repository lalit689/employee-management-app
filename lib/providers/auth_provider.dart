import 'package:flutter/material.dart';

/// Manages login/authentication state.
/// This is a simple LOCAL/DEMO login as allowed by the task
/// (no paid authentication service is used).
class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Demo credentials for the local/demo login.
  static const String _demoEmail = 'admin@example.com';
  static const String _demoPassword = 'admin123';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate a small network/auth delay for realistic UX.
    await Future.delayed(const Duration(milliseconds: 600));

    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail == _demoEmail && password == _demoPassword) {
      _isLoggedIn = true;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoggedIn = false;
      _errorMessage = 'Invalid email or password. Try admin@example.com / admin123';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }
}
