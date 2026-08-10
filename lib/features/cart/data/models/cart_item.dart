class CartItem {
  final int id;
  final String productId;
  final String productName;
  final String productImageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String currency;
  final String provider;
  final String stockStatus;
  final bool isAvailable;
  final double priceWhenAdded;
  final double currentPrice;
  final bool priceDropped;
  final double savingsAmount;
  final String? configId;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.currency,
    required this.provider,
    required this.stockStatus,
    required this.isAvailable,
    required this.priceWhenAdded,
    required this.currentPrice,
    required this.priceDropped,
    required this.savingsAmount,
    this.configId,
  });

  factory CartItem.fromJson(
    Map<String, dynamic> json, {
    String defaultCurrency = 'ETB',
  }) {
    final Map<String, dynamic>? pricing =
        json['pricing'] as Map<String, dynamic>?;
    final double unitPrice = _readDouble(
      pricing?['unitPrice'] ?? json['unitPrice'],
    );
    final double totalPrice = _readDouble(
      pricing?['totalPrice'] ?? json['subtotal'] ?? json['totalPrice'],
      fallback: unitPrice,
    );

    final String productId =
        (json['productId'] as String? ?? json['itemId'] as String? ?? '')
            .trim();

    return CartItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: productId,
      productName: (json['productName'] as String?)?.trim().isNotEmpty == true
          ? json['productName'] as String
          : productId,
      productImageUrl: json['productImageUrl'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: unitPrice,
      subtotal: totalPrice,
      currency: (json['currency'] as String?)?.trim().isNotEmpty == true
          ? json['currency'] as String
          : defaultCurrency,
      provider: json['provider'] as String? ?? '',
      stockStatus: json['stockStatus'] as String? ?? 'IN_STOCK',
      isAvailable: json['isAvailable'] as bool? ?? true,
      priceWhenAdded: _readDouble(
        json['priceWhenAdded'],
        fallback: unitPrice,
      ),
      currentPrice: _readDouble(
        json['currentPrice'],
        fallback: unitPrice,
      ),
      priceDropped: json['priceDropped'] as bool? ?? false,
      savingsAmount: _readDouble(json['savingsAmount']),
      configId: (json['configId'] ?? json['config_id']) as String?,
    );
  }

  static double _readDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'currency': currency,
      'provider': provider,
      'stockStatus': stockStatus,
      'isAvailable': isAvailable,
      'priceWhenAdded': priceWhenAdded,
      'currentPrice': currentPrice,
      'priceDropped': priceDropped,
      'savingsAmount': savingsAmount,
      if (configId != null) 'configId': configId,
    };
  }
}
