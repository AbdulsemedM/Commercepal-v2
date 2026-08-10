import 'payment_flow_constants.dart';

class PricingSummary {
  final num? subtotal;
  final num? discountAmount;
  final num? deliveryFee;
  final num? additionalCharges;
  final num? totalAmount;
  final String? currency;

  PricingSummary({
    this.subtotal,
    this.discountAmount,
    this.deliveryFee,
    this.additionalCharges,
    this.totalAmount,
    this.currency,
  });

  factory PricingSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PricingSummary();
    return PricingSummary(
      subtotal: json['subtotal'] as num?,
      discountAmount: json['discountAmount'] as num?,
      deliveryFee: json['deliveryFee'] as num?,
      additionalCharges: json['additionalCharges'] as num?,
      totalAmount: json['totalAmount'] as num?,
      currency: json['currency'] as String?,
    );
  }
}

class PaymentInitiation {
  final bool? success;
  final String? orderNumber;
  final String? paymentReference;
  final String? paymentProviderCode;
  final String? paymentUrl;
  final String? paymentInstructions;
  final String? nextAction;
  final String? ussdCode;
  final String? instructions;
  final String? expiresAt;
  final String? qrCode;
  final String? qrData;

  PaymentInitiation({
    this.success,
    this.orderNumber,
    this.paymentReference,
    this.paymentProviderCode,
    this.paymentUrl,
    this.paymentInstructions,
    this.nextAction,
    this.ussdCode,
    this.instructions,
    this.expiresAt,
    this.qrCode,
    this.qrData,
  });

  factory PaymentInitiation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PaymentInitiation();
    return PaymentInitiation(
      success: json['success'] as bool?,
      orderNumber: json['orderNumber'] as String?,
      paymentReference: json['paymentReference'] as String?,
      paymentProviderCode: json['paymentProviderCode'] as String?,
      paymentUrl: json['paymentUrl'] as String?,
      paymentInstructions: json['paymentInstructions'] as String?,
      nextAction: json['nextAction'] as String?,
      ussdCode: json['ussdCode'] as String?,
      instructions: json['instructions'] as String?,
      expiresAt: json['expiresAt'] as String?,
      qrCode: json['qrCode'] as String?,
      qrData: json['qrData'] as String?,
    );
  }

  String? get resolvedInstructions {
    final String fromInstructions = instructions?.trim() ?? '';
    if (fromInstructions.isNotEmpty) return fromInstructions;
    return paymentInstructions?.trim();
  }

  String? get resolvedUssdCode {
    final String code = ussdCode?.trim() ?? '';
    return code.isEmpty ? null : code;
  }

  /// Prefers qrData, then qrCode, then paymentUrl (EMV QR payload).
  String? get resolvedQrPayload {
    for (final String? candidate in <String?>[qrData, qrCode, paymentUrl]) {
      final String value = candidate?.trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return null;
  }
}

class CheckoutResponse {
  final String? orderNumber;
  final String? platform;
  final String? currency;
  final PricingSummary? pricingSummary;
  final String? paymentStatus;
  final String? orderedAt;
  final PaymentInitiation? paymentInitiation;
  final String? paymentUrl;
  final String? ussdCode;
  final num? totalAmount;

  CheckoutResponse({
    this.orderNumber,
    this.platform,
    this.currency,
    this.pricingSummary,
    this.paymentStatus,
    this.orderedAt,
    this.paymentInitiation,
    this.paymentUrl,
    this.ussdCode,
    this.totalAmount,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderNumber: json['orderNumber'] as String?,
      platform: json['platform'] as String?,
      currency: json['currency'] as String?,
      pricingSummary: json['pricingSummary'] != null
          ? PricingSummary.fromJson(
              json['pricingSummary'] as Map<String, dynamic>?,
            )
          : null,
      paymentStatus: json['paymentStatus'] as String?,
      orderedAt: json['orderedAt'] as String?,
      paymentInitiation: json['paymentInitiation'] != null
          ? PaymentInitiation.fromJson(
              json['paymentInitiation'] as Map<String, dynamic>?,
            )
          : null,
      paymentUrl: json['paymentUrl'] as String?,
      ussdCode: json['ussdCode'] as String?,
      totalAmount: json['totalAmount'] as num?,
    );
  }

  bool get isDocsCheckoutResponse {
    if (paymentInitiation != null) return false;
    final String order = orderNumber?.trim() ?? '';
    if (order.isEmpty) return false;
    final bool hasDocsFields = (paymentUrl?.trim().isNotEmpty ?? false) ||
        (ussdCode?.trim().isNotEmpty ?? false) ||
        totalAmount != null;
    return hasDocsFields;
  }

  /// Resolved [nextAction] from paymentInitiation.
  String? get resolvedNextAction {
    final String fromInit = paymentInitiation?.nextAction?.trim() ?? '';
    return fromInit.isEmpty ? null : fromInit;
  }

  /// Resolved payment URL from initiation or top-level field.
  String? get resolvedPaymentUrl {
    final String fromInit = paymentInitiation?.paymentUrl?.trim() ?? '';
    if (fromInit.isNotEmpty) return fromInit;
    final String top = paymentUrl?.trim() ?? '';
    return top.isEmpty ? null : top;
  }

  /// Resolved USSD code from initiation or top-level field.
  String? get resolvedUssdCode {
    final String fromInit = paymentInitiation?.resolvedUssdCode ?? '';
    if (fromInit.isNotEmpty) return fromInit;
    final String top = ussdCode?.trim() ?? '';
    return top.isEmpty ? null : top;
  }

  /// QR payload for bank-app scan (QPay `SHOW_QR_CODE` / `SCAN_QR`).
  String? get resolvedQrPayload {
    final String? fromInit = paymentInitiation?.resolvedQrPayload;
    if (fromInit != null && fromInit.isNotEmpty) return fromInit;
    final String top = paymentUrl?.trim() ?? '';
    return top.isEmpty ? null : top;
  }

  num? get resolvedTotalAmount =>
      totalAmount ?? pricingSummary?.totalAmount;

  static const String nextActionOpenAdditionalInput =
      NextAction.openAdditionalInput;
  static const String nextActionRedirectToPaymentUrl =
      NextAction.redirectToPaymentUrl;
  static const String nextActionScanQr = NextAction.scanQr;
  static const String nextActionShowQrCode = NextAction.showQrCode;
  static const String nextActionUssdCode = NextAction.ussdCode;
  static const String nextActionSuccess = NextAction.success;
  static const String nextActionPending = NextAction.pending;

  /// Cart may be cleared only when payment is immediately complete (e.g. COD).
  bool get isCheckoutCompleteForCartClear {
    final String action = resolvedNextAction ?? '';
    if (action == nextActionSuccess) {
      return resolvedOrderNumber?.isNotEmpty ?? false;
    }
    final String status = (paymentStatus ?? '').trim().toUpperCase();
    return status == PaymentStatus.success;
  }

  /// Order was reserved with payment still pending (HTTP checkout may be 200
  /// even when [PaymentInitiation.success] is false).
  bool get isOrderReservedPaymentPending {
    final status = (paymentStatus ?? '').trim().toUpperCase();
    if (status != PaymentStatus.pending) return false;
    final order = resolvedOrderNumber;
    return order != null && order.isNotEmpty;
  }

  /// Non-empty [paymentInitiation.paymentReference] when present (for display).
  String? get paymentReferenceOrNull {
    final r = paymentInitiation?.paymentReference?.trim() ?? '';
    return r.isEmpty ? null : r;
  }

  /// Resolved order number for display and retry routes.
  String? get resolvedOrderNumber {
    final top = orderNumber?.trim() ?? '';
    if (top.isNotEmpty) return top;
    final io = paymentInitiation?.orderNumber?.trim() ?? '';
    return io.isEmpty ? null : io;
  }
}
