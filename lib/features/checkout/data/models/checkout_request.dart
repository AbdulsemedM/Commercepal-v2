import 'shipping_address.dart';

class CheckoutItem {
  final String itemId;
  final String? configId;
  final int quantity;
  final num? unitPrice;

  CheckoutItem({
    required this.itemId,
    this.configId,
    required this.quantity,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        if (configId != null &&
            configId!.isNotEmpty &&
            configId != '0') 'configId': configId,
        'quantity': quantity,
        if (unitPrice != null && unitPrice! > 0) 'unitPrice': unitPrice,
      };
}

class CheckoutRequest {
  final String channel;
  final String currency;
  final int deliveryAddressId;
  final List<CheckoutItem> items;
  final String paymentProviderCode;
  final String? paymentAccount;
  final String? promoCode;
  final String? referralCode;

  CheckoutRequest({
    required this.channel,
    required this.currency,
    required this.deliveryAddressId,
    required this.items,
    required this.paymentProviderCode,
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
        if (paymentAccount != null && paymentAccount!.isNotEmpty) 'paymentAccount': paymentAccount!,
        if (promoCode != null) 'promoCode': promoCode,
        if (referralCode != null) 'referralCode': referralCode,
      };
}

enum DocsPaymentMethod {
  telebirr('TELEBIRR'),
  cbeBirr('CBE_BIRR'),
  eBirr('E_BIRR'),
  ziina('ZIINA');

  const DocsPaymentMethod(this.apiValue);

  final String apiValue;
}

class DocsCheckoutRequest {
  final int cartId;
  final ShippingAddress shippingAddress;
  final DocsPaymentMethod paymentMethod;
  final String notes;

  DocsCheckoutRequest({
    required this.cartId,
    required this.shippingAddress,
    required this.paymentMethod,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cartId': cartId,
        'shippingAddress': shippingAddress.toJson(),
        'paymentMethod': paymentMethod.apiValue,
        'notes': notes,
      };
}
