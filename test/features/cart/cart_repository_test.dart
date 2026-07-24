import 'package:commercepal/features/checkout/data/models/checkout_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkout payload from cart item fields', () {
    test('maps stored cart fields to CheckoutItem', () {
      const itemId = 'aesg-1005012526670058';
      const configId = 'variant-red';
      const quantity = 2;
      const unitPrice = 1396.0;

      final checkoutItem = CheckoutItem(
        itemId: itemId,
        configId: configId,
        quantity: quantity,
        unitPrice: unitPrice,
      );

      expect(checkoutItem.toJson(), {
        'itemId': itemId,
        'configId': configId,
        'quantity': quantity,
        'unitPrice': unitPrice,
      });
    });
  });
}
