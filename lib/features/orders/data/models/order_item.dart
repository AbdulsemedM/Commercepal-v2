class OrderItem {
  final String subOrderNumber;
  final String productName;
  final String productImageUrl;
  final String productConfiguration;
  final double unitPrice;
  final int quantity;
  final double subTotal;
  final String currency;
  final String itemStage;
  final String itemStageLabel;
  final String productId;

  OrderItem({
    required this.subOrderNumber,
    required this.productName,
    required this.productImageUrl,
    required this.productConfiguration,
    required this.unitPrice,
    required this.quantity,
    required this.subTotal,
    required this.currency,
    required this.itemStage,
    required this.itemStageLabel,
    this.productId = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // New API: name, image, quantity, status
    final productName = json['productName'] as String? ?? json['name'] as String? ?? '';
    final productImageUrl = json['productImageUrl'] as String? ?? json['image'] as String? ?? '';
    final quantity = json['quantity'] as int? ?? 0;
    final itemStage = json['itemStage'] as String? ?? json['status'] as String? ?? '';
    final itemStageLabel = json['itemStageLabel'] as String? ?? itemStage;
    final unitPrice = (json['unitPrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0;
    final subTotal = (json['subTotal'] as num?)?.toDouble() ?? (json['subtotal'] as num?)?.toDouble() ?? unitPrice * quantity;
    return OrderItem(
      subOrderNumber: json['subOrderNumber'] as String? ?? '',
      productName: productName,
      productImageUrl: productImageUrl,
      productConfiguration: json['productConfiguration'] as String? ?? '',
      unitPrice: unitPrice,
      quantity: quantity,
      subTotal: subTotal,
      currency: json['currency'] as String? ?? 'ETB',
      itemStage: itemStage,
      itemStageLabel: itemStageLabel,
      productId: json['productId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'subOrderNumber': subOrderNumber,
        'productName': productName,
        'productImageUrl': productImageUrl,
        'productConfiguration': productConfiguration,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'subTotal': subTotal,
        'currency': currency,
        'itemStage': itemStage,
        'itemStageLabel': itemStageLabel,
        'productId': productId,
      };
}
