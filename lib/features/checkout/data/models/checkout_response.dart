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
}
