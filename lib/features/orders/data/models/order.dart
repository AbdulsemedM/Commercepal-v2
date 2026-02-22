import 'order_item.dart';
import 'delivery_address.dart';

/// Single entry from order detail API orderStageHistory.
class OrderStageHistoryEntry {
  final String stage;
  final String stageLabel;
  final String previousStage;
  final String previousStageLabel;
  final String enteredAt;
  final String changedBy;

  OrderStageHistoryEntry({
    required this.stage,
    required this.stageLabel,
    required this.previousStage,
    required this.previousStageLabel,
    required this.enteredAt,
    required this.changedBy,
  });

  factory OrderStageHistoryEntry.fromJson(Map<String, dynamic> json) {
    return OrderStageHistoryEntry(
      stage: json['stage'] as String? ?? '',
      stageLabel: json['stageLabel'] as String? ?? '',
      previousStage: json['previousStage'] as String? ?? '',
      previousStageLabel: json['previousStageLabel'] as String? ?? '',
      enteredAt: json['enteredAt'] as String? ?? '',
      changedBy: json['changedBy'] as String? ?? '',
    );
  }
}

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
  /// Payment reference for retry/initiate payment (e.g. CP-20260222-XXX).
  final String? paymentReference;
  final String paymentStatus;
  final String paymentStatusLabel;
  final bool hasException;
  final String exceptionMessage;
  final String? paidAt;
  final List<OrderStageHistoryEntry>? orderStageHistory;

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
    this.paymentReference,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.hasException,
    required this.exceptionMessage,
    this.paidAt,
    this.orderStageHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();

    // New API: orderedAt (ISO date), status, actions{ canPay, canTrack }
    final orderedAt = json['orderedAt'] as String?;
    final orderDate = json['orderDate'] as String? ?? orderedAt ?? '';
    final status = json['status'] as String? ?? '';
    final actions = json['actions'] as Map<String, dynamic>?;
    final canPayFromApi = json['canPay'] as bool? ?? (actions?['canPay'] == true);
    final isWaitingForPayment = status.toLowerCase().contains('waiting') && status.toLowerCase().contains('payment');
    final canPay = canPayFromApi || isWaitingForPayment;
    final canTrack = json['canTrack'] as bool? ?? (actions?['canTrack'] == true);

    final payment = json['payment'] as Map<String, dynamic>?;
    final paymentReference = json['paymentReference'] as String? ?? payment?['reference'] as String?;

    // Detail API: payment { status, paidAt, reference }
    final paymentStatus = payment?['status'] as String? ?? json['paymentStatus'] as String? ?? '';
    final paidAt = payment?['paidAt'] as String?;

    // Detail API: summary { subtotal, delivery, discount, total }
    final summary = json['summary'] as Map<String, dynamic>?;
    final subtotalVal = summary?['subtotal'] as num? ?? json['subtotal'] as num?;
    final totalVal = summary?['total'] as num? ?? json['totalAmount'] as num?;
    final subtotal = (subtotalVal != null) ? subtotalVal.toDouble() : 0.0;
    final totalAmount = (totalVal != null) ? totalVal.toDouble() : 0.0;

    // Detail API: orderStageHistory
    final historyJson = json['orderStageHistory'] as List<dynamic>? ?? [];
    final orderStageHistory = historyJson
        .map((e) => OrderStageHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    final orderStageHistoryOrNull = orderStageHistory.isEmpty ? null : orderStageHistory;

    return Order(
      orderNumber: json['orderNumber'] as String? ?? '',
      orderDate: orderDate,
      orderId: json['orderId'] as int? ?? 0,
      currentStage: json['currentStage'] as String? ?? status,
      stageLabel: json['stageLabel'] as String? ?? status,
      stageCategory: json['stageCategory'] as String? ?? 'ALL',
      statusDescription: json['statusDescription'] as String? ?? status,
      items: items,
      totalItemsCount: json['totalItemsCount'] as int? ?? items.length,
      subtotal: subtotal,
      totalAmount: totalAmount,
      currency: json['currency'] as String? ?? 'ETB',
      deliveryAddress: DeliveryAddress.fromJson(
        json['deliveryAddress'] as Map<String, dynamic>? ?? {},
      ),
      storeName: json['storeName'] as String? ?? '',
      storeIconUrl: json['storeIconUrl'] as String? ?? '',
      canConfirmReceived: json['canConfirmReceived'] as bool? ?? false,
      canTrack: canTrack,
      canCancel: json['canCancel'] as bool? ?? false,
      canReturn: json['canReturn'] as bool? ?? false,
      canPay: canPay,
      canReview: json['canReview'] as bool? ?? false,
      paymentReference: paymentReference,
      paymentStatus: paymentStatus,
      paymentStatusLabel: json['paymentStatusLabel'] as String? ?? paymentStatus,
      hasException: json['hasException'] as bool? ?? false,
      exceptionMessage: json['exceptionMessage'] as String? ?? '',
      paidAt: paidAt,
      orderStageHistory: orderStageHistoryOrNull,
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
        if (paymentReference != null) 'paymentReference': paymentReference,
        'paymentStatus': paymentStatus,
        'paymentStatusLabel': paymentStatusLabel,
        'hasException': hasException,
        'exceptionMessage': exceptionMessage,
        if (paidAt != null) 'paidAt': paidAt,
        if (orderStageHistory != null)
          'orderStageHistory':
              orderStageHistory!.map((e) => {
                    'stage': e.stage,
                    'stageLabel': e.stageLabel,
                    'previousStage': e.previousStage,
                    'previousStageLabel': e.previousStageLabel,
                    'enteredAt': e.enteredAt,
                    'changedBy': e.changedBy,
                  }).toList(),
      };
}
