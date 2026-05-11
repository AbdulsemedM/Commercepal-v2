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

  PaymentInitiation({
    this.success,
    this.orderNumber,
    this.paymentReference,
    this.paymentProviderCode,
    this.paymentUrl,
    this.paymentInstructions,
    this.nextAction,
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
    );
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

  CheckoutResponse({
    this.orderNumber,
    this.platform,
    this.currency,
    this.pricingSummary,
    this.paymentStatus,
    this.orderedAt,
    this.paymentInitiation,
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
    );
  }

  /// Backend [nextAction] values we treat as a completed checkout for cart clearing.
  static const String nextActionOpenAdditionalInput = 'OPEN_ADDITIONAL_INPUT';
  static const String nextActionRedirectToPaymentUrl = 'REDIRECT_TO_PAYMENT_URL';

  /// When true, the order is reserved and payment started; safe to clear the cart.
  /// Based on [paymentInitiation] (not HTTP status alone).
  bool get isCheckoutCompleteForCartClear {
    final init = paymentInitiation;
    if (init == null) return false;
    if (init.success != true) return false;

    final top = orderNumber?.trim() ?? '';
    final initOrder = init.orderNumber?.trim() ?? '';
    if (top.isNotEmpty && initOrder.isNotEmpty && top != initOrder) {
      return false;
    }
    final resolvedOrder = top.isNotEmpty ? top : initOrder;
    if (resolvedOrder.isEmpty) return false;

    final ref = init.paymentReference?.trim() ?? '';
    if (ref.isEmpty) return false;

    final action = init.nextAction?.trim() ?? '';
    if (action.isEmpty) return false;

    if (action == nextActionRedirectToPaymentUrl) {
      final url = init.paymentUrl?.trim() ?? '';
      return url.isNotEmpty;
    }
    if (action == nextActionOpenAdditionalInput) {
      final instructions = init.paymentInstructions?.trim() ?? '';
      return instructions.isNotEmpty;
    }
    return false;
  }

  /// Non-empty [paymentInitiation.paymentReference] when present (for retry flow).
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
