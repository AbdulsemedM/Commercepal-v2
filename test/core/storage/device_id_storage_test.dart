import 'package:commercepal/core/storage/storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Storage.getOrCreateDeviceId', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('persists UUID fallback and returns same id on second call', () async {
      final Storage storage = Storage();

      final String first = await storage.getOrCreateDeviceId();
      final String second = await storage.getOrCreateDeviceId();

      expect(first, isNotEmpty);
      expect(second, first);
      expect(await storage.getDeviceId(), first);
    });

    test('returns existing persisted device id without regenerating', () async {
      FlutterSecureStorage.setMockInitialValues({
        'device_id': 'existing-device-id',
      });
      final Storage storage = Storage();

      expect(await storage.getOrCreateDeviceId(), 'existing-device-id');
      expect(await storage.getOrCreateDeviceId(), 'existing-device-id');
    });
  });

  group('Storage.getOrCreateRememberMeKey', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('creates 32-byte key and reuses it', () async {
      final Storage storage = Storage();

      final first = await storage.getOrCreateRememberMeKey();
      final second = await storage.getOrCreateRememberMeKey();

      expect(first.length, 32);
      expect(second, first);
    });
  });
}
