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
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        subOrderNumber: json['subOrderNumber'] as String,
        productName: json['productName'] as String,
        productImageUrl: json['productImageUrl'] as String? ?? '',
        productConfiguration: json['productConfiguration'] as String? ?? '',
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: json['quantity'] as int,
        subTotal: (json['subTotal'] as num).toDouble(),
        currency: json['currency'] as String,
        itemStage: json['itemStage'] as String? ?? '',
        itemStageLabel: json['itemStageLabel'] as String? ?? '',
      );

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
      };
}
