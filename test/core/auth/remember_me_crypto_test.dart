import 'package:commercepal/core/auth/remember_me_crypto.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RememberMeCrypto', () {
    late Storage storage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = Storage();
    });

    test('encrypt/decrypt round-trip without device-id binding', () async {
      const password = 's3cret-password';

      final String? cipher =
          await RememberMeCrypto.encryptPassword(storage, password);
      expect(cipher, isNotNull);
      expect(cipher, isNotEmpty);

      final String? clear =
          await RememberMeCrypto.tryDecryptPassword(storage, cipher!);
      expect(clear, password);
    });

    test('returns null when cipher is garbage', () async {
      final String? clear = await RememberMeCrypto.tryDecryptPassword(
        storage,
        'not-valid-base64-cipher!!!',
      );
      expect(clear, isNull);
    });

    test('returns null after remember-me credentials are cleared', () async {
      final String? cipher =
          await RememberMeCrypto.encryptPassword(storage, 'password');
      expect(cipher, isNotNull);

      await storage.clearRememberMeCredentials();

      // New secret after clear — old ciphertext must not decrypt.
      final String? clear =
          await RememberMeCrypto.tryDecryptPassword(storage, cipher!);
      expect(clear, isNull);
    });
  });
}
