import 'package:firebase_analytics/firebase_analytics.dart';

/// Lightweight funnel events (no backend change).
class AppAnalytics {
  AppAnalytics._();

  static final FirebaseAnalytics _a = FirebaseAnalytics.instance;

  static Future<void> logViewItem({
    required String itemId,
    String? itemName,
    String? currency,
    double? value,
  }) async {
    await _a.logViewItem(
      items: <AnalyticsEventItem>[
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          currency: currency,
          price: value,
        ),
      ],
      currency: currency,
      value: value,
    );
  }

  static Future<void> logAddToCart({
    required String itemId,
    String? currency,
    double? value,
  }) async {
    await _a.logAddToCart(
      currency: currency,
      value: value,
      items: <AnalyticsEventItem>[
        AnalyticsEventItem(
          itemId: itemId,
          currency: currency,
          price: value,
          quantity: 1,
        ),
      ],
    );
  }

  static Future<void> logBeginCheckout({double? value, String? currency}) async {
    await _a.logBeginCheckout(value: value, currency: currency);
  }

  static Future<void> logSearch({required String searchTerm}) async {
    await _a.logSearch(searchTerm: searchTerm);
  }
}
