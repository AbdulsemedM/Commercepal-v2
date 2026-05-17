import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  PlatformUtils._();

  /// Get the platform channel name (ANDROID, IOS, or WEB)
  static String getChannel() {
    if (kIsWeb) {
      return 'WEB';
    } else if (Platform.isAndroid) {
      return 'MOBILE_APP_ANDROID';
    } else if (Platform.isIOS) {
      return 'MOBILE_APP_IOS';
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

  /// Google Sign-In is omitted on Apple OS native builds; shown on Android and web.
  static bool get shouldShowGoogleSignInButton {
    if (kIsWeb) {
      return true;
    }
    return !Platform.isIOS && !Platform.isMacOS;
  }
}

