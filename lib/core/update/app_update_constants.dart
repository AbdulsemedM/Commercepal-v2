/// Fallback store URLs when not provided by Remote Config.
class AppUpdateConstants {
  AppUpdateConstants._();

  static const String storeUrlAndroid =
      'https://play.google.com/store/apps/details?id=com.commercepal.commercepal';

  /// Replace with your App Store link from App Store Connect, or set via Remote Config.
  static const String storeUrlIos =
      'https://apps.apple.com/app/com.commercepal/id'; // append App Store ID if known
}
