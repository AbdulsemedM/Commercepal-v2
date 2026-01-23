import 'order_item.dart';
import 'delivery_address.dart';

class Order {
  final String orderNumber;
  final String orderDate;
  final int orderId;
  final String currentStage;
  final String stageLabel;
  final String stageCategory;
  final String statusDescription;
  final List<OrderItem> items;
  final int totalItemsCount;
  final double subtotal;
  final double totalAmount;
  final String currency;
  final DeliveryAddress deliveryAddress;
  final String storeName;
  final String storeIconUrl;
  final bool canConfirmReceived;
  final bool canTrack;
  final bool canCancel;
  final bool canReturn;
  final bool canPay;
  final bool canReview;
  final String paymentStatus;
  final String paymentStatusLabel;
  final bool hasException;
  final String exceptionMessage;

  Order({
    required this.orderNumber,
    required this.orderDate,
    required this.orderId,
    required this.currentStage,
    required this.stageLabel,
    required this.stageCategory,
    required this.statusDescription,
    required this.items,
    required this.totalItemsCount,
    required this.subtotal,
    required this.totalAmount,
    required this.currency,
    required this.deliveryAddress,
    required this.storeName,
    required this.storeIconUrl,
    required this.canConfirmReceived,
    required this.canTrack,
    required this.canCancel,
    required this.canReturn,
    required this.canPay,
    required this.canReview,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.hasException,
    required this.exceptionMessage,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Order(
      orderNumber: json['orderNumber'] as String,
      orderDate: json['orderDate'] as String,
      orderId: json['orderId'] as int,
      currentStage: json['currentStage'] as String? ?? '',
      stageLabel: json['stageLabel'] as String? ?? '',
      stageCategory: json['stageCategory'] as String? ?? 'ALL',
      statusDescription: json['statusDescription'] as String? ?? '',
      items: items,
      totalItemsCount: json['totalItemsCount'] as int? ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
      deliveryAddress: DeliveryAddress.fromJson(
        json['deliveryAddress'] as Map<String, dynamic>? ?? {},
      ),
      storeName: json['storeName'] as String? ?? '',
      storeIconUrl: json['storeIconUrl'] as String? ?? '',
      canConfirmReceived: json['canConfirmReceived'] as bool? ?? false,
      canTrack: json['canTrack'] as bool? ?? false,
      canCancel: json['canCancel'] as bool? ?? false,
      canReturn: json['canReturn'] as bool? ?? false,
      canPay: json['canPay'] as bool? ?? false,
      canReview: json['canReview'] as bool? ?? false,
      paymentStatus: json['paymentStatus'] as String? ?? '',
      paymentStatusLabel: json['paymentStatusLabel'] as String? ?? '',
      hasException: json['hasException'] as bool? ?? false,
      exceptionMessage: json['exceptionMessage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'orderNumber': orderNumber,
        'orderDate': orderDate,
        'orderId': orderId,
        'currentStage': currentStage,
        'stageLabel': stageLabel,
        'stageCategory': stageCategory,
        'statusDescription': statusDescription,
        'items': items.map((item) => item.toJson()).toList(),
        'totalItemsCount': totalItemsCount,
        'subtotal': subtotal,
        'totalAmount': totalAmount,
        'currency': currency,
        'deliveryAddress': deliveryAddress.toJson(),
        'storeName': storeName,
        'storeIconUrl': storeIconUrl,
        'canConfirmReceived': canConfirmReceived,
        'canTrack': canTrack,
        'canCancel': canCancel,
        'canReturn': canReturn,
        'canPay': canPay,
        'canReview': canReview,
        'paymentStatus': paymentStatus,
        'paymentStatusLabel': paymentStatusLabel,
        'hasException': hasException,
        'exceptionMessage': exceptionMessage,
      };
}
