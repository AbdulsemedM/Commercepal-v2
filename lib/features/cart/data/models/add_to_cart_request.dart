import '../../utils/cart_product_id.dart';

class AddToCartItem {
  final String productId;
  final String configId;
  final int quantity;
  final String currency;
  final String country;

  AddToCartItem({
    required this.productId,
    required this.configId,
    required this.quantity,
    required this.currency,
    required this.country,
  });

  /// Docs cart body — productId, configId, quantity only (headers carry locale).
  Map<String, dynamic> toJson() => <String, dynamic>{
        'productId': normalizeCartProductId(productId),
        'configId': configId,
        'quantity': quantity,
      };
}

class AddToCartRequest {
  final List<AddToCartItem> items;

  AddToCartRequest({required this.items});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'items': items.map((AddToCartItem item) => item.toJson()).toList(),
      };
}
