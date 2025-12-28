// Auth service to manage user login state
import 'package:flutter/foundation.dart';

import '../core/storage/storage.dart';
import '../features/auth/logout/data/repository/logout_repository.dart';

class AuthService extends ChangeNotifier {
  AuthService._({Storage? storage, LogoutRepository? logoutRepository})
    : _storage = storage ?? Storage(),
      _logoutRepository = logoutRepository ?? LogoutRepository() {
    _checkAuthStatus();
  }

  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final Storage _storage;
  final LogoutRepository _logoutRepository;
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

  Future<void> _checkAuthStatus() async {
    final hasTokens = await _storage.hasTokens();
    if (hasTokens) {
      _isLoggedIn = true;
      _userEmail = await _storage.getUserEmail();
      if (_userEmail != null && _userEmail!.isNotEmpty) {
        _userInitials = _userEmail!.substring(0, 1).toUpperCase();
      }
      notifyListeners();
    }
  }

  // Set user as logged in
  void login({String? userName, String? userEmail, String? userImageUrl}) {
    _isLoggedIn = true;
    _userName = userName;
    _userEmail = userEmail;
    _userImageUrl = userImageUrl;

    // Generate initials from name or email
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

  Future<void> logout() async {
    try {
      // Call logout API endpoint
      await _logoutRepository.logout();
    } catch (e) {
      // Even if API call fails, clear local state
      // This ensures user can logout even if offline
      await _storage.clearTokens();
    }

    // Clear local state regardless of API call result
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
