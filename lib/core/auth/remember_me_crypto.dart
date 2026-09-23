import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

import 'package:commercepal/core/storage/storage.dart';

/// AES-GCM for remember-me password storage.
///
/// Key material is a random secret in flutter_secure_storage (Keychain /
/// Keystore), not a client-generated device UUID. Device IDs must not be used
/// as a cryptographic security control (CWE-330).
///
/// Token/session data uses flutter_secure_storage v10+ (AES-GCM, not CBC).
/// Residual MobSF CBC hits may still appear from other Google SDK bytecode.
class RememberMeCrypto {
  RememberMeCrypto._();

  static final List<int> _pepper = utf8.encode('commercepal-rm-v2-pepper');

  static Future<SecretKey> _secretKey(Storage storage) async {
    final List<int> keyBytes = await storage.getOrCreateRememberMeKey();
    final List<int> input = keyBytes + _pepper;
    final Digest digest = sha256.convert(input);
    return SecretKey(digest.bytes);
  }

  static Future<String?> encryptPassword(Storage storage, String password) async {
    final AesGcm algorithm = AesGcm.with256bits();
    final SecretKey secretKey = await _secretKey(storage);
    final SecretBox box = await algorithm.encrypt(
      utf8.encode(password),
      secretKey: secretKey,
    );
    return base64Encode(box.concatenation());
  }

  /// Returns null if decryption fails (including legacy deviceId-derived
  /// ciphertext from older app versions).
  static Future<String?> tryDecryptPassword(
    Storage storage,
    String cipherBase64,
  ) async {
    try {
      final AesGcm algorithm = AesGcm.with256bits();
      final SecretKey secretKey = await _secretKey(storage);
      final List<int> concatenation = base64Decode(cipherBase64);
      final SecretBox box = SecretBox.fromConcatenation(
        concatenation,
        nonceLength: algorithm.nonceLength,
        macLength: algorithm.macAlgorithm.macLength,
      );
      final List<int> clear = await algorithm.decrypt(
        box,
        secretKey: secretKey,
      );
      return utf8.decode(clear);
    } catch (_) {
      return null;
    }
  }
}
