class PaymentMethodVariant {
  final String displayName;
  final String variantCode;
  final String currency;
  final String iconUrl;
  final String? paymentInstruction;

  PaymentMethodVariant({
    required this.displayName,
    required this.variantCode,
    required this.currency,
    required this.iconUrl,
    this.paymentInstruction,
  });

  factory PaymentMethodVariant.fromJson(Map<String, dynamic> json) {
    return PaymentMethodVariant(
      displayName: json['displayName'] as String? ?? '',
      variantCode: json['variantCode'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      paymentInstruction: json['paymentInstruction'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'variantCode': variantCode,
        'currency': currency,
        'iconUrl': iconUrl,
        if (paymentInstruction != null) 'paymentInstruction': paymentInstruction,
      };
}
