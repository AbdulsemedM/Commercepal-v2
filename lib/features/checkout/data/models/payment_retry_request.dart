/// Request body for POST /api/v1/payments/retry
class PaymentRetryRequest {
  final String paymentReference;
  final String paymentProviderCode;
  final String paymentProviderVariantCode;

  PaymentRetryRequest({
    required this.paymentReference,
    required this.paymentProviderCode,
    required this.paymentProviderVariantCode,
  });

  Map<String, dynamic> toJson() => {
        'paymentReference': paymentReference,
        'paymentProviderCode': paymentProviderCode,
        'paymentProviderVariantCode': paymentProviderVariantCode,
      };
}
