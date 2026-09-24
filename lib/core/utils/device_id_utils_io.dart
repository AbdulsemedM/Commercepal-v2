import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

const MethodChannel _androidIdChannel =
    MethodChannel('com.commercepal.commercepal/android_id');

/// Platform-supported device identifier, or null when unavailable.
///
/// - Android: [Settings.Secure.ANDROID_ID] via app MethodChannel
/// - iOS: `identifierForVendor`
///
/// Does **not** generate a UUID fallback; callers persist a UUID once if null.
Future<String?> tryGetPlatformDeviceId() async {
  try {
    if (Platform.isAndroid) {
      final String? androidId =
          await _androidIdChannel.invokeMethod<String>('getId');
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
