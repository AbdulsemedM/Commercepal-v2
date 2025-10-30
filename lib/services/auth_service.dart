// Auth service to manage user login state
// For frontend-only development, using in-memory state
// TODO: Replace with actual authentication service when backend is integrated
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  bool _isLoggedIn = false;
  String? _userName;
  String? _userEmail;
  String? _userInitials;
  String? _userImageUrl;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userInitials => _userInitials;
  String? get userImageUrl => _userImageUrl;

  // Set user as logged in (for testing/demo purposes)
  void login({
    String? userName,
    String? userEmail,
    String? userImageUrl,
  }) {
    _isLoggedIn = true;
    _userName = userName ?? 'Tafari Mwangi';
    _userEmail = userEmail ?? 'tafaris@gmail.com';
    _userImageUrl = userImageUrl;

    // Generate initials from name
    if (_userName != null && _userName!.isNotEmpty) {
      final List<String> parts = _userName!.trim().split(' ');
      if (parts.length >= 2) {
        _userInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        _userInitials = _userName!.substring(0, 1).toUpperCase();
      }
    } else if (_userEmail != null && _userEmail!.isNotEmpty) {
      _userInitials = _userEmail!.substring(0, 1).toUpperCase();
    } else {
      _userInitials = 'U';
    }

    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _userInitials = null;
    _userImageUrl = null;
    notifyListeners();
  }

  // Update user profile
  void updateProfile({
    String? userName,
    String? userEmail,
    String? userImageUrl,
  }) {
    if (userName != null) {
      _userName = userName;
      // Regenerate initials
      if (_userName!.isNotEmpty) {
        final List<String> parts = _userName!.trim().split(' ');
        if (parts.length >= 2) {
          _userInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else {
          _userInitials = _userName!.substring(0, 1).toUpperCase();
        }
      }
    }
    if (userEmail != null) {
      _userEmail = userEmail;
    }
    if (userImageUrl != null) {
      _userImageUrl = userImageUrl;
    }
    notifyListeners();
  }
}



