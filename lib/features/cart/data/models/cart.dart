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
    return Cart(
      cartId: json['cartId'] as int,
      totalItems: json['totalItems'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      estimatedTotal: (json['estimatedTotal'] as num).toDouble(),
      currency: json['currency'] as String,
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      priceDropItems: (json['priceDropItems'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      unavailableItems: (json['unavailableItems'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalSavings: (json['totalSavings'] as num).toDouble(),
    );
  }
}

