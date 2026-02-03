import 'device_id_utils_io.dart'
    if (dart.library.html) 'device_id_utils_web.dart'
    as impl;

class DeviceIdUtils {
  DeviceIdUtils._();

  /// Get a device identifier for API requests.
  /// Uses device_info_plus on mobile, UUID on web.
  static Future<String> getDeviceId() => impl.getDeviceId();
}
