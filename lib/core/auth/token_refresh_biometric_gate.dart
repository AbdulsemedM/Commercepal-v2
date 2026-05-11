import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/biometric_service.dart';
import 'package:commercepal/services/localization_service.dart';

/// Thrown when refresh is blocked because biometric was cancelled or failed.
class RefreshBiometricDenied implements Exception {
  const RefreshBiometricDenied();
}

/// Prompts for biometrics immediately before a refresh-token network call when
/// the user has enabled biometric protection. Foreground grace avoids repeated
/// prompts; [onAppBackgrounded] clears that window.
class TokenRefreshBiometricGate {
  TokenRefreshBiometricGate._();
  static final TokenRefreshBiometricGate instance = TokenRefreshBiometricGate._();

  static const Duration _foregroundGrace = Duration(minutes: 12);

  DateTime? _lastRefreshUnlockAt;

  void onAppBackgrounded() {
    _lastRefreshUnlockAt = null;
  }

  /// Returns true when refresh may proceed (biometric passed, disabled, or grace).
  Future<bool> ensureUnlockedForRefresh() async {
    final Storage storage = Storage();
    final bool biometricEnabled = await storage.getBiometricEnabled();
    if (!biometricEnabled) {
      return true;
    }

    final BiometricService biometricService = BiometricService();
    if (!await biometricService.hasEnrolledBiometrics) {
      return true;
    }

    final DateTime? last = _lastRefreshUnlockAt;
    if (last != null &&
        DateTime.now().difference(last) < _foregroundGrace) {
      return true;
    }

    await LocalizationService.ensureInitialized();
    final String locale = await storage.getLocale();
    final String reason = LocalizationService.tForLanguage(
      locale,
      'auth.biometric.refreshSessionReason',
    );

    final BiometricAuthResult result =
        await biometricService.authenticate(reason: reason);
    if (result != BiometricAuthResult.success) {
      return false;
    }

    _lastRefreshUnlockAt = DateTime.now();
    return true;
  }
}
