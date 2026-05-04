import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Result of a biometric authentication attempt.
enum BiometricAuthResult {
  success,
  failure,
  cancel,
  unavailable,
}

/// Wraps [LocalAuthentication] for biometric (Face ID / Touch ID / fingerprint) auth.
class BiometricService {
  BiometricService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  /// Whether the device can check biometrics (hardware support).
  Future<bool> get canCheckBiometrics => _auth.canCheckBiometrics;

  /// Whether the device supports local auth (biometric or device credential).
  Future<bool> get isDeviceSupported => _auth.isDeviceSupported();

  /// List of enrolled biometric types (e.g. fingerprint, face).
  Future<List<BiometricType>> getAvailableBiometrics() {
    return _auth.getAvailableBiometrics();
  }

  /// Returns true if at least one biometric is available and enrolled.
  Future<bool> get hasEnrolledBiometrics async {
    final canCheck = await canCheckBiometrics;
    if (!canCheck) return false;
    final list = await getAvailableBiometrics();
    return list.isNotEmpty;
  }

  /// Authenticate the user with biometrics. [reason] is shown in the system dialog.
  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final supported = await isDeviceSupported;
      if (!supported) return BiometricAuthResult.unavailable;

      final success = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return success ? BiometricAuthResult.success : BiometricAuthResult.failure;
    } on PlatformException catch (e, stackTrace) {
      debugPrint(
        '[BiometricService] PlatformException code=${e.code} message=${e.message}',
      );
      debugPrint(stackTrace.toString());
      final msg = '${e.code} ${e.message ?? ''}'.toLowerCase();
      if (msg.contains('cancel') ||
          msg.contains('user_canceled') ||
          msg.contains('user canceled') ||
          msg.contains('not_enrolled')) {
        return BiometricAuthResult.cancel;
      }
      if (msg.contains('lockout') ||
          msg.contains('unavailable') ||
          msg.contains('not_available')) {
        return BiometricAuthResult.unavailable;
      }
      return BiometricAuthResult.failure;
    } catch (e, stackTrace) {
      debugPrint('[BiometricService] Unexpected error: $e');
      debugPrint(stackTrace.toString());
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') ||
          msg.contains('user_canceled') ||
          msg.contains('user canceled') ||
          msg.contains('not_enrolled')) {
        return BiometricAuthResult.cancel;
      }
      if (msg.contains('lockout') ||
          msg.contains('unavailable') ||
          msg.contains('not_available')) {
        return BiometricAuthResult.unavailable;
      }
      return BiometricAuthResult.failure;
    }
  }
}
