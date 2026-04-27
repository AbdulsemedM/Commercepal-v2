import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/update/app_update_check_result.dart';
import 'package:commercepal/core/update/app_update_check_service.dart';
import 'package:commercepal/core/update/app_update_modal.dart';
import 'package:commercepal/services/biometric_service.dart';
import 'package:commercepal/services/localization_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Storage _storage = Storage();

  @override
  void initState() {
    super.initState();
    _runSplashAndVersionCheck();
  }

  Future<void> _navigateAfterAuth() async {
    if (!mounted) return;

    await _storage.markAppOpened();
    if (mounted) context.go(AppRoutes.dashboard);
  }

  Future<void> _proceedToApp() async {
    final bool biometricOk = await _unlockWithBiometricIfNeeded();
    if (!mounted) return;
    if (!biometricOk) {
      context.go(AppRoutes.login);
      return;
    }
    await _navigateAfterAuth();
  }

  Future<void> _runSplashAndVersionCheck() async {
    const Duration minSplashDuration = Duration(seconds: 2);

    final results = await Future.wait(<Future<dynamic>>[
      Future<void>.delayed(minSplashDuration),
      AppUpdateCheckService.check(),
    ]);

    final AppUpdateCheckResult result = results[1] as AppUpdateCheckResult;

    if (!mounted) return;

    if (result.hasUpdate) {
      await AppUpdateModal.show(
        context,
        result: result,
        onLater: () {
          if (mounted) {
            _proceedToApp();
          }
        },
      );
      return;
    }

    await _proceedToApp();
  }

  /// When the user enabled biometric login and tokens exist, require a successful
  /// biometric prompt before entering the app. Hardware or enrollment issues skip the gate.
  Future<bool> _unlockWithBiometricIfNeeded() async {
    final bool hasTokens = await _storage.hasTokens();
    final bool biometricEnabled = await _storage.getBiometricEnabled();
    if (!hasTokens || !biometricEnabled) return true;

    final BiometricService biometricService = BiometricService();
    if (!await biometricService.hasEnrolledBiometrics) return true;

    if (!mounted) return true;
    final String reason = LocalizationService.t(
      context,
      'auth.biometric.signInReason',
    );
    final BiometricAuthResult result =
        await biometricService.authenticate(reason: reason);
    return result == BiometricAuthResult.success;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Primary background color layer
          Container(color: Theme.of(context).primaryColor),

          // Wavy SVG background overlay
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/background.svg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Centered logo
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 220,
              fit: BoxFit.contain,
            ),
          ),

          // Bottom loading indicator
          Align(
            alignment: const Alignment(0, 0.85),
            child: SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
