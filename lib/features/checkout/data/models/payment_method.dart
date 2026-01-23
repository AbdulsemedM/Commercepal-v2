import 'payment_method_item.dart';

class PaymentMethod {
  final String displayName;
  final String code;
  final String iconUrl;
  final List<PaymentMethodItem> paymentMethodItemResponses;

  PaymentMethod({
    required this.displayName,
    required this.code,
    required this.iconUrl,
    required this.paymentMethodItemResponses,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['paymentMethodItemResponses'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((item) => PaymentMethodItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaymentMethod(
      displayName: json['displayName'] as String? ?? '',
      code: json['code'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      paymentMethodItemResponses: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'code': code,
        'iconUrl': iconUrl,
        'paymentMethodItemResponses':
            paymentMethodItemResponses.map((item) => item.toJson()).toList(),
      };
}
