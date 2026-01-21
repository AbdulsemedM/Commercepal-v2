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
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImageUrl: json['productImageUrl'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      currency: json['currency'] as String,
      provider: json['provider'] as String,
      stockStatus: json['stockStatus'] as String,
      isAvailable: json['isAvailable'] as bool,
      priceWhenAdded: (json['priceWhenAdded'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      priceDropped: json['priceDropped'] as bool,
      savingsAmount: (json['savingsAmount'] as num).toDouble(),
    );
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
    };
  }
}

