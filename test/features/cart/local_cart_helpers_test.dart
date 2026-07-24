import 'package:commercepal/features/cart/data/data_provider/local_cart_data_provider.dart';
import 'package:commercepal/features/cart/data/models/cart_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeCartConfigId', () {
    test('treats empty and zero as null', () {
      expect(normalizeCartConfigId(null), isNull);
      expect(normalizeCartConfigId(''), isNull);
      expect(normalizeCartConfigId('0'), isNull);
      expect(normalizeCartConfigId('  '), isNull);
    });

    test('preserves non-empty variant ids', () {
      expect(normalizeCartConfigId('variant-1'), 'variant-1');
      expect(normalizeCartConfigId('__BASE__'), '__BASE__');
    });
  });

  group('cartItemsMatchVariant', () {
    CartItem item({String? configId}) {
      return CartItem(
        id: 1,
        productId: 'prod-1',
        productName: 'Test',
        productImageUrl: '',
        quantity: 1,
        unitPrice: 100,
        subtotal: 100,
        currency: 'ETB',
        provider: 'aliexpress',
        stockStatus: 'IN_STOCK',
        isAvailable: true,
        priceWhenAdded: 100,
        currentPrice: 100,
        priceDropped: false,
        savingsAmount: 0,
        configId: configId,
      );
    }

    test('matches same product and base config', () {
      expect(
        cartItemsMatchVariant(item(configId: null), 'prod-1', ''),
        isTrue,
      );
      expect(
        cartItemsMatchVariant(item(configId: '0'), 'prod-1', null),
        isTrue,
      );
    });

    test('does not merge different variants', () {
      expect(
        cartItemsMatchVariant(item(configId: 'red'), 'prod-1', 'blue'),
        isFalse,
      );
      expect(
        cartItemsMatchVariant(item(configId: 'red'), 'prod-1', 'red'),
        isTrue,
      );
    });
  });
}
