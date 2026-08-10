class PaymentInitiateResult {
  const PaymentInitiateResult({
    this.ussdCode,
    this.referenceCode,
    this.referenceNumber,
    this.paymentUrl,
    this.message,
    this.paymentInstructions,
  });

  final String? ussdCode;
  final String? referenceCode;
  final String? referenceNumber;
  final String? paymentUrl;
  final String? message;
  final String? paymentInstructions;

  String? get resolvedReference => referenceCode ?? referenceNumber;

  factory PaymentInitiateResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _unwrapData(json);
    return PaymentInitiateResult(
      ussdCode: _string(data['ussdCode']),
      referenceCode: _string(data['referenceCode']),
      referenceNumber: _string(data['referenceNumber']),
      paymentUrl: _string(data['paymentUrl']),
      message: _string(data['message']),
      paymentInstructions: _string(data['paymentInstructions']),
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
