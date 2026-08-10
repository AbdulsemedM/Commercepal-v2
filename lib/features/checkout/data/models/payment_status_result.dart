class PaymentStatusResult {
  const PaymentStatusResult({
    required this.paymentStatus,
    this.orderStatus,
  });

  final String paymentStatus;
  final String? orderStatus;

  bool get isSuccess => paymentStatus.toUpperCase() == 'SUCCESS';

  bool get isFailed => paymentStatus.toUpperCase() == 'FAILED';

  bool get isPending {
    final String status = paymentStatus.toUpperCase();
    return status == 'PENDING' || status == 'UNPAID' || status.isEmpty;
  }

  factory PaymentStatusResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _unwrapData(json);
    return PaymentStatusResult(
      paymentStatus: _string(data['paymentStatus']) ?? 'PENDING',
      orderStatus: _string(data['orderStatus']),
    );
  }

  static Map<String, dynamic> _unwrapData(Map<String, dynamic> json) {
    final Object? data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return json;
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
