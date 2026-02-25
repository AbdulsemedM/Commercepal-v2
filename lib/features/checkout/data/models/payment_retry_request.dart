/// Request body for POST /api/v1/payments/retry
class PaymentRetryRequest {
  final String paymentReference;
  final String paymentProviderCode;
  final String? paymentAccount;

  PaymentRetryRequest({
    required this.paymentReference,
    required this.paymentProviderCode,
    this.paymentAccount,
  });

  Map<String, dynamic> toJson() => {
        'paymentReference': paymentReference,
        'paymentProviderCode': paymentProviderCode,
        if (paymentAccount?.isNotEmpty == true) 'paymentAccount': paymentAccount!,
      };
}
