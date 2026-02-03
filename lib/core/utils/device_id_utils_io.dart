import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

Future<String> getDeviceId() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? const Uuid().v4();
    }
  } catch (_) {
    // Fallback on any error
  }
  return const Uuid().v4();
}
