import 'cart_item.dart';

class Cart {
  final int cartId;
  final int totalItems;
  final double subtotal;
  final double estimatedTotal;
  final String currency;
  final DateTime lastActivityAt;
  final List<CartItem> items;
  final List<CartItem> priceDropItems;
  final List<CartItem> unavailableItems;
  final double totalSavings;

  Cart({
    required this.cartId,
    required this.totalItems,
    required this.subtotal,
    required this.estimatedTotal,
    required this.currency,
    required this.lastActivityAt,
    required this.items,
    required this.priceDropItems,
    required this.unavailableItems,
    required this.totalSavings,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? totals =
        json['totals'] as Map<String, dynamic>?;
    final String currency = (totals?['currency'] as String?)?.trim().isNotEmpty ==
            true
        ? totals!['currency'] as String
        : (json['currency'] as String?)?.trim().isNotEmpty == true
            ? json['currency'] as String
            : 'ETB';

    final List<CartItem> items = (json['items'] as List<dynamic>?)
            ?.map(
              (dynamic item) => CartItem.fromJson(
                item as Map<String, dynamic>,
                defaultCurrency: currency,
              ),
            )
            .toList() ??
        <CartItem>[];

    final int totalItems = (json['totalItems'] as num?)?.toInt() ??
        items.fold<int>(0, (int sum, CartItem item) => sum + item.quantity);

    final double subtotal = (totals?['subtotal'] as num?)?.toDouble() ??
        (json['subtotal'] as num?)?.toDouble() ??
        items.fold<double>(0, (double sum, CartItem item) => sum + item.subtotal);

    final double estimatedTotal = (totals?['total'] as num?)?.toDouble() ??
        (json['estimatedTotal'] as num?)?.toDouble() ??
        subtotal;

    return Cart(
      cartId: (json['cartId'] as num?)?.toInt() ?? 0,
      totalItems: totalItems,
      subtotal: subtotal,
      estimatedTotal: estimatedTotal,
      currency: currency,
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.tryParse(json['lastActivityAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: items,
      priceDropItems: (json['priceDropItems'] as List<dynamic>?)
              ?.map(
                (dynamic item) => CartItem.fromJson(
                  item as Map<String, dynamic>,
                  defaultCurrency: currency,
                ),
              )
              .toList() ??
          <CartItem>[],
      unavailableItems: (json['unavailableItems'] as List<dynamic>?)
              ?.map(
                (dynamic item) => CartItem.fromJson(
                  item as Map<String, dynamic>,
                  defaultCurrency: currency,
                ),
              )
              .toList() ??
          <CartItem>[],
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'totalItems': totalItems,
      'subtotal': subtotal,
      'estimatedTotal': estimatedTotal,
      'currency': currency,
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'items': items.map((CartItem e) => e.toJson()).toList(),
      'priceDropItems': priceDropItems.map((CartItem e) => e.toJson()).toList(),
      'unavailableItems':
          unavailableItems.map((CartItem e) => e.toJson()).toList(),
      'totalSavings': totalSavings,
    };
  }
}
