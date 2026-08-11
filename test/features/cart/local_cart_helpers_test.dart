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

  CartItem item({
    String? configId,
    String productId = 'prod-1',
    double unitPrice = 100,
  }) {
    return CartItem(
      id: 1,
      productId: productId,
      productName: 'Test',
      productImageUrl: '',
      quantity: 1,
      unitPrice: unitPrice,
      subtotal: unitPrice,
      currency: 'ETB',
      provider: 'aliexpress',
      stockStatus: 'IN_STOCK',
      isAvailable: true,
      priceWhenAdded: unitPrice,
      currentPrice: unitPrice,
      priceDropped: false,
      savingsAmount: 0,
      configId: configId,
    );
  }

  group('isPurchasableCartItem', () {
    test('keeps rows with an id and a price', () {
      expect(isPurchasableCartItem(item()), isTrue);
    });

    test('drops rows saved from a degraded catalog record', () {
      expect(isPurchasableCartItem(item(productId: '')), isFalse);
      expect(isPurchasableCartItem(item(productId: '   ')), isFalse);
      expect(isPurchasableCartItem(item(unitPrice: 0)), isFalse);
    });
  });

  group('cartItemsMatchVariant', () {
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

    test('matches same product ignoring cp- prefix', () {
      expect(
        cartItemsMatchVariant(item(productId: 'cp-prod-1'), 'prod-1', null),
        isTrue,
      );
      expect(
        cartItemsMatchVariant(item(productId: 'prod-1'), 'cp-prod-1', ''),
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
