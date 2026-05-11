import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:commercepal/features/orders/data/models/order.dart';

/// Persists last successful order payload for offline viewing on the tracking screen.
class OrderTrackingCache {
  OrderTrackingCache._();

  static Future<File> _file(String orderNumber) async {
    final dir = await getApplicationDocumentsDirectory();
    final safe = orderNumber.replaceAll(RegExp(r'[^\w\-]+'), '_');
    return File('${dir.path}/order_track_cache_$safe.json');
  }

  static Future<void> save(Order order) async {
    try {
      final f = await _file(order.orderNumber);
      await f.writeAsString(jsonEncode(order.toJson()));
    } catch (_) {}
  }

  static Future<Order?> load(String orderNumber) async {
    try {
      final f = await _file(orderNumber);
      if (!await f.exists()) return null;
      final map = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return Order.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
