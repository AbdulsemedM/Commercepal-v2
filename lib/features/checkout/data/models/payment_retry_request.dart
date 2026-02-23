/// Request body for POST /api/v1/payments/retry
class PaymentRetryRequest {
  final String paymentReference;
  final String paymentProviderCode;
  final String paymentProviderVariantCode;
  final String? paymentAccount;

  PaymentRetryRequest({
    required this.paymentReference,
    required this.paymentProviderCode,
    required this.paymentProviderVariantCode,
    this.paymentAccount,
  });

  Map<String, dynamic> toJson() => {
        'paymentReference': paymentReference,
        'paymentProviderCode': paymentProviderCode,
        'paymentProviderVariantCode': paymentProviderVariantCode,
        if (paymentAccount?.isNotEmpty == true) 'paymentAccount': paymentAccount!,
      };
}
