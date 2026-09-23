import 'package:commercepal/core/storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Storage.androidSecureOptions', () {
    test('uses AES-GCM storage and RSA-OAEP key wrap', () {
      final options = Storage.androidSecureOptions.toMap();

      expect(options['storageCipherAlgorithm'], 'AES_GCM_NoPadding');
      expect(
        options['keyCipherAlgorithm'],
        'RSA_ECB_OAEPwithSHA_256andMGF1Padding',
      );
      expect(options['migrateOnAlgorithmChange'], 'true');
    });

    test('does not use deprecated encryptedSharedPreferences', () {
      final options = Storage.androidSecureOptions.toMap();

      // Intentionally false: Jetpack EncryptedSharedPreferences is deprecated
      // in flutter_secure_storage v10 and removed in v11.
      expect(options['encryptedSharedPreferences'], 'false');
    });
  });
}
