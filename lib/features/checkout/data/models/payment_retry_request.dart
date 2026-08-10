/// Request body for POST /api/v1/orders/{orderNumber}/retry-payment
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
}
