class CheckoutItem {
  final String itemId;
  final String? configId;
  final int quantity;

  CheckoutItem({
    required this.itemId,
    this.configId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        if (configId != null && configId!.isNotEmpty) 'configId': configId,
        'quantity': quantity,
      };
}

class CheckoutRequest {
  final String channel;
  final String currency;
  final int deliveryAddressId;
  final List<CheckoutItem> items;
  final String paymentProviderCode;
  final String paymentProviderVariantCode;
  final String? paymentAccount;
  final String? promoCode;
  final String? referralCode;

  CheckoutRequest({
    required this.channel,
    required this.currency,
    required this.deliveryAddressId,
    required this.items,
    required this.paymentProviderCode,
    required this.paymentProviderVariantCode,
    this.paymentAccount,
    this.promoCode,
    this.referralCode,
  });

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'currency': currency,
        'deliveryAddressId': deliveryAddressId,
        'items': items.map((item) => item.toJson()).toList(),
        'paymentProviderCode': paymentProviderCode,
        'paymentProviderVariantCode': paymentProviderVariantCode,
        if (paymentAccount != null) 'paymentAccount': paymentAccount,
        if (promoCode != null) 'promoCode': promoCode,
        if (referralCode != null) 'referralCode': referralCode,
      };
}
