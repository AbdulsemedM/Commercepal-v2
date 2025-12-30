import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  PlatformUtils._();

  /// Get the platform channel name (ANDROID, IOS, or WEB)
  static String getChannel() {
    if (kIsWeb) {
      return 'WEB';
    } else if (Platform.isAndroid) {
      return 'ANDROID';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else {
      return 'WEB';
    }
  }

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Web
  static bool get isWeb => kIsWeb;
}

