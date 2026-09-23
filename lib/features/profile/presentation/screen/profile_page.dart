import 'package:flutter/material.dart';
import 'package:commercepal/features/auth/login/presentation/screen/login_screen.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/features/profile/presentation/widgets/profile_content.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.isActive = true});

  /// When false (another dashboard tab is selected), do not mount [LoginScreen].
  /// IndexedStack keeps this page alive, and an offstage login PopScope can
  /// hijack back navigation and jump to the profile login UI.
  final bool isActive;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.isLoggedIn) {
      return const ProfileContent();
    }
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }
    return const LoginScreen(hideBackButton: true);
  }
}
