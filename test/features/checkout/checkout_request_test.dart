import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/features/checkout/data/models/checkout_request.dart';
import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutRequest', () {
    test('serializes web-style checkout body', () {
      final request = CheckoutRequest(
        channel: PlatformUtils.getChannel(),
        currency: 'ETB',
        deliveryAddressId: 36107,
        items: <CheckoutItem>[
          CheckoutItem(
            itemId: 'cj-2082038593248079874',
            configId: '2082038593566846977',
            quantity: 3,
          ),
        ],
        paymentProviderCode: PaymentConstants.toCheckoutProviderCode('TELEBIRR'),
        paymentAccount: '251946514836',
        idempotencyKey: 'checkout-02545213-ad93-4c28-9f05-dae30cd0d12d',
        promoCode: null,
      );

      expect(request.toJson(), <String, dynamic>{
        'channel': PlatformUtils.getChannel(),
        'currency': 'ETB',
        'deliveryAddressId': 36107,
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'itemId': 'cj-2082038593248079874',
            'configId': '2082038593566846977',
            'quantity': 3,
          },
        ],
        'paymentProviderCode': 'TELE_BIRR',
        'paymentAccount': '251946514836',
        'idempotencyKey': 'checkout-02545213-ad93-4c28-9f05-dae30cd0d12d',
        'promoCode': null,
      });
    });

    test('omits paymentAccount when null', () {
      final request = CheckoutRequest(
        channel: PlatformUtils.getChannel(),
        currency: 'ETB',
        deliveryAddressId: 2,
        items: <CheckoutItem>[
          CheckoutItem(itemId: 'cj-1', quantity: 1),
        ],
        paymentProviderCode: 'CBE_BIRR',
        idempotencyKey: 'checkout-test',
      );

      final json = request.toJson();
      expect(json.containsKey('paymentAccount'), isFalse);
      expect(json.containsKey('cartId'), isFalse);
      expect(json['items'], isNotEmpty);
    });

    test('PayPal checkout omits paymentAccount', () {
      final request = CheckoutRequest(
        channel: PlatformUtils.getChannel(),
        currency: 'ETB',
        deliveryAddressId: 10,
        items: <CheckoutItem>[
          CheckoutItem(itemId: 'cj-2', quantity: 1),
        ],
        paymentProviderCode: 'PAYPAL',
        idempotencyKey: 'checkout-paypal',
      );

      final json = request.toJson();
      expect(json['paymentProviderCode'], 'PAYPAL');
      expect(json.containsKey('paymentAccount'), isFalse);
    });
  });

  group('PaymentConstants.toCheckoutProviderCode', () {
    test('maps TELEBIRR to TELE_BIRR', () {
      expect(PaymentConstants.toCheckoutProviderCode('TELEBIRR'), 'TELE_BIRR');
      expect(PaymentConstants.toCheckoutProviderCode('TELE_BIRR'), 'TELE_BIRR');
      expect(PaymentConstants.toCheckoutProviderCode('CBE_BIRR'), 'CBE_BIRR');
    });
  });
}
