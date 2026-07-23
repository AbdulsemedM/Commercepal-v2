import 'package:commercepal/features/checkout/data/models/checkout_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutItem', () {
    test('includes unitPrice in JSON when provided', () {
      final item = CheckoutItem(
        itemId: 'alb-1600171362033',
        quantity: 2,
        unitPrice: 3640,
      );

      expect(item.toJson(), {
        'itemId': 'alb-1600171362033',
        'quantity': 2,
        'unitPrice': 3640,
      });
    });

    test('omits unitPrice when zero or null', () {
      final item = CheckoutItem(
        itemId: 'alb-1600171362033',
        quantity: 1,
        unitPrice: 0,
      );

      expect(item.toJson(), {
        'itemId': 'alb-1600171362033',
        'quantity': 1,
      });
    });
  });

  group('CheckoutRequest', () {
    test('omits paymentAccount when null', () {
      final request = CheckoutRequest(
        channel: 'MOBILE_APP_ANDROID',
        currency: 'ETB',
        deliveryAddressId: 36107,
        items: [
          CheckoutItem(
            itemId: 'alb-1600171362033',
            quantity: 2,
            unitPrice: 3640,
          ),
        ],
        paymentProviderCode: 'CASH',
      );

      final json = request.toJson();
      expect(json['paymentProviderCode'], 'CASH');
      expect(json.containsKey('paymentAccount'), isFalse);
      expect(json['items'], [
        {
          'itemId': 'alb-1600171362033',
          'quantity': 2,
          'unitPrice': 3640,
        },
      ]);
    });
  });
}
