/// Fallback store URLs when not provided by Remote Config.
class AppUpdateConstants {
  AppUpdateConstants._();

  static const String _packageIdAndroid = 'com.commercepal.commercepal';

  /// HTTPS URL for Play Store (works in browser and often in Play Store app).
  static const String storeUrlAndroid =
      'https://play.google.com/store/apps/details?id=$_packageIdAndroid';

  /// market: intent opens the Play Store app directly on Android.
  static const String storeIntentAndroid =
      'market://details?id=$_packageIdAndroid';

  /// Replace with your App Store link from App Store Connect, or set via Remote Config.
  static const String storeUrlIos =
      'https://apps.apple.com/app/com.commercepal/id'; // append App Store ID if known
}
