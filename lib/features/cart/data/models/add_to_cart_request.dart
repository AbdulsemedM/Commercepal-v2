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

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'configId': configId,
    'quantity': quantity,
    'currency': currency,
    'country': country,
  };
}

class AddToCartRequest {
  final List<AddToCartItem> items;

  AddToCartRequest({required this.items});

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
  };
}

