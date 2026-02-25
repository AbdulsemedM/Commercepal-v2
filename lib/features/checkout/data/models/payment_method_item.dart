import 'payment_method_variant.dart';

class PaymentMethodItem {
  final String displayName;
  final String itemCode;
  final String currency;
  final String iconUrl;
  final String? paymentInstruction;
  final bool? requireAccountNumberOnInitiation;
  final List<PaymentMethodVariant> paymentMethodItemResponses;

  PaymentMethodItem({
    required this.displayName,
    required this.itemCode,
    required this.currency,
    required this.iconUrl,
    this.paymentInstruction,
    this.requireAccountNumberOnInitiation,
    required this.paymentMethodItemResponses,
  });

  factory PaymentMethodItem.fromJson(Map<String, dynamic> json) {
    final variantsJson = json['paymentMethodItemResponses'] as List<dynamic>? ?? [];
    final variants = variantsJson
        .map((item) => PaymentMethodVariant.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaymentMethodItem(
      displayName: json['displayName'] as String? ?? '',
      itemCode: json['itemCode'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      paymentInstruction: json['paymentInstruction'] as String?,
      requireAccountNumberOnInitiation:
          json['requireAccountNumberOnInitiation'] as bool?,
      paymentMethodItemResponses: variants,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'itemCode': itemCode,
        'currency': currency,
        'iconUrl': iconUrl,
        if (paymentInstruction != null) 'paymentInstruction': paymentInstruction,
        if (requireAccountNumberOnInitiation != null)
          'requireAccountNumberOnInitiation': requireAccountNumberOnInitiation,
        'paymentMethodItemResponses':
            paymentMethodItemResponses.map((v) => v.toJson()).toList(),
      };

  /// Check if this item has variants
  bool get hasVariants => paymentMethodItemResponses.isNotEmpty;
}
