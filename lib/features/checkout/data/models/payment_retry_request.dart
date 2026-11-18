/// Retry a failed payment: POST /api/payments/retry.
class PaymentRetryRequest {
  final String paymentProviderCode;
  final String? paymentAccount;

  PaymentRetryRequest({
    required this.paymentProviderCode,
    this.paymentAccount,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'paymentProviderCode': paymentProviderCode,
        if (paymentAccount?.isNotEmpty == true) 'paymentAccount': paymentAccount!,
      };

  /// Body for POST /api/payments/retry. The backend retries with the payment
  /// phone stored on the order, so [paymentAccount] is not sent.
  Map<String, dynamic> toBackendJson(String orderNumber) => <String, dynamic>{
        'paymentReference': orderNumber,
        'paymentProviderCode': paymentProviderCode,
      };
}
