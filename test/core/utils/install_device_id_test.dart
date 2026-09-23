import 'package:commercepal/core/utils/install_device_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveInstallDeviceId', () {
    test('prefers persisted value over platform and UUID', () {
      expect(
        resolveInstallDeviceId(
          persisted: 'persisted-id',
          platformId: 'platform-id',
          fallbackUuid: 'uuid-fallback',
        ),
        'persisted-id',
      );
    });

    test('uses platform ID when nothing persisted', () {
      expect(
        resolveInstallDeviceId(
          persisted: null,
          platformId: 'android-or-idfv',
          fallbackUuid: 'uuid-fallback',
        ),
        'android-or-idfv',
      );
    });

    test('falls back to UUID when platform ID unavailable', () {
      expect(
        resolveInstallDeviceId(
          persisted: '',
          platformId: null,
          fallbackUuid: 'uuid-fallback',
        ),
        'uuid-fallback',
      );
      expect(
        resolveInstallDeviceId(
          persisted: '   ',
          platformId: '',
          fallbackUuid: 'uuid-fallback',
        ),
        'uuid-fallback',
      );
    });

    test('trims whitespace on persisted and platform values', () {
      expect(
        resolveInstallDeviceId(
          persisted: '  kept  ',
          platformId: null,
          fallbackUuid: 'uuid',
        ),
        'kept',
      );
      expect(
        resolveInstallDeviceId(
          persisted: null,
          platformId: '  platform  ',
          fallbackUuid: 'uuid',
        ),
        'platform',
      );
    });
  });
}
