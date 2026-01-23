import 'payment_method.dart';

class PaymentMethodsResponse {
  final int status;
  final String message;
  final List<PaymentMethod> data;

  PaymentMethodsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as List<dynamic>? ?? [];
    final paymentMethods = dataJson
        .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaymentMethodsResponse(
      status: json['status'] as int? ?? 200,
      message: json['message'] as String? ?? 'Success',
      data: paymentMethods,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.map((method) => method.toJson()).toList(),
      };
}
