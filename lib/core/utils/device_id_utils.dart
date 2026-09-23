import 'package:commercepal/core/storage/storage.dart';

import 'device_id_utils_io.dart'
    if (dart.library.html) 'device_id_utils_web.dart'
    as impl;

class DeviceIdUtils {
  DeviceIdUtils._();

  /// Platform-supported ID (ANDROID_ID / IDFV), or null if unavailable.
  static Future<String?> tryGetPlatformDeviceId() =>
      impl.tryGetPlatformDeviceId();

  /// Install-scoped device identifier for API requests.
  ///
  /// Delegates to [Storage.getOrCreateDeviceId] so affiliate, cart, FCM, and
  /// auth share one persisted ID (platform ID preferred, else UUID once).
  static Future<String> getDeviceId() => Storage().getOrCreateDeviceId();
}
