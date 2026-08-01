import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/router/app_router.dart';
import '../core/logging/app_logger.dart';

/// Routes CommercePal push-notification / deep-link payloads into the app.
///
/// Expected data payload:
/// `{ "type": "order" | "cart" | "coupon", "id": "...", "url": "..." }`
class DeeplinkService {
  DeeplinkService._();

  static final DeeplinkService instance = DeeplinkService._();

  /// Handles a notification data map (FCM `message.data` or decoded local payload).
  void handleNotificationData(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    if (kDebugMode) {
      AppLogger.i('Handling notification deep link', data: data);
    }

    final type = (data['type'] ?? '').toString().toLowerCase().trim();
    final id = (data['id'] ?? '').toString().trim();
    final url = (data['url'] ?? '').toString().trim();

    switch (type) {
      case 'order':
        if (id.isNotEmpty) {
          appRouter.push(
            Uri(
              path: AppRoutes.orderSummary,
              queryParameters: <String, String>{'id': id},
            ).toString(),
          );
          return;
        }
        appRouter.push(AppRoutes.orderHistory);
        return;
      case 'cart':
        appRouter.go('${AppRoutes.dashboard}?tab=2');
        return;
      case 'coupon':
        if (url.isNotEmpty) {
          _openExternalUrl(url);
          return;
        }
        // No in-app coupons screen yet — open dashboard home as fallback.
        appRouter.go(AppRoutes.dashboard);
        return;
      default:
        if (url.isNotEmpty) {
          _openExternalUrl(url);
        }
    }
  }

  /// Parses a local-notification payload string into a data map, then routes.
  void handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        handleNotificationData(Map<String, dynamic>.from(decoded));
        return;
      }
    } catch (_) {
      // Legacy payloads may be Map.toString(); ignore unparseable strings.
      if (kDebugMode) {
        AppLogger.w('Unparseable notification payload', data: {'payload': payload});
      }
    }
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      AppLogger.e('Failed to open notification URL', error: e, stack: st);
    }
  }
}
