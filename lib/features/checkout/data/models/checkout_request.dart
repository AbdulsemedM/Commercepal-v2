/// Checkout line item matching production web checkout.
class CheckoutItem {
  final String itemId;
  final String? configId;
  final int quantity;

  CheckoutItem({
    required this.itemId,
    this.configId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'itemId': itemId,
        if (configId != null &&
            configId!.isNotEmpty &&
            configId != '0')
          'configId': configId,
        'quantity': quantity,
      };
}

/// POST /api/v1/orders/checkout — matches production web checkout body.
class CheckoutRequest {
  final String channel;
  final String currency;
  final int deliveryAddressId;
  final List<CheckoutItem> items;
  final String paymentProviderCode;
  final String? paymentAccount;
  final String idempotencyKey;
  final String? promoCode;

  CheckoutRequest({
    required this.channel,
    required this.currency,
    required this.deliveryAddressId,
    required this.items,
    required this.paymentProviderCode,
    required this.idempotencyKey,
    this.paymentAccount,
    this.promoCode,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'channel': channel,
        'currency': currency,
        'deliveryAddressId': deliveryAddressId,
        'items': items.map((CheckoutItem item) => item.toJson()).toList(),
        'paymentProviderCode': paymentProviderCode,
        if (paymentAccount != null && paymentAccount!.isNotEmpty)
          'paymentAccount': paymentAccount!,
        'idempotencyKey': idempotencyKey,
        'promoCode': promoCode,
      };
}

enum DocsPaymentMethod {
  telebirr('TELE_BIRR'),
  cbeBirr('CBE_BIRR'),
  eBirr('E_BIRR'),
  ziina('ZIINA');

  const DocsPaymentMethod(this.apiValue);

  final String apiValue;
}
