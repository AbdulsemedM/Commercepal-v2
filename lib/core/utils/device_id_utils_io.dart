import 'dart:io' show Platform;

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Platform-supported device identifier, or null when unavailable.
///
/// - Android: [Settings.Secure.ANDROID_ID] via the `android_id` package
/// - iOS: `identifierForVendor`
///
/// Does **not** generate a UUID fallback; callers persist a UUID once if null.
Future<String?> tryGetPlatformDeviceId() async {
  try {
    if (Platform.isAndroid) {
      final String? androidId = await const AndroidId().getId();
      if (androidId != null && androidId.isNotEmpty) {
        return androidId;
      }
      return null;
    }
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final String? idfv = iosInfo.identifierForVendor;
      if (idfv != null && idfv.isNotEmpty) {
        return idfv;
      }
      return null;
    }
  } catch (_) {
    // Plugin missing or platform error — treat as unavailable.
  }
  return null;
}
