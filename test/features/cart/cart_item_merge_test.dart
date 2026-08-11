import 'package:commercepal/features/cart/data/models/cart_item.dart';
import 'package:commercepal/features/cart/utils/cart_item_merge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CartItem item({
    required int id,
    String productId = 'prod-1',
    String? configId,
    int quantity = 1,
    double unitPrice = 100,
  }) {
    return CartItem(
      id: id,
      productId: productId,
      productName: 'Test',
      productImageUrl: '',
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: unitPrice * quantity,
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

  group('mergeDuplicateCartItems', () {
    test('merges identical product and config into one line with summed qty', () {
      final result = mergeDuplicateCartItems(<CartItem>[
        item(id: 10, quantity: 1),
        item(id: 20, quantity: 2),
      ]);

      expect(result.items, hasLength(1));
      expect(result.items.single.id, 10);
      expect(result.items.single.quantity, 3);
      expect(result.items.single.subtotal, 300);
      expect(result.extraLineIdsToDelete, <int>[20]);
      expect(result.quantityUpdates, <int, int>{10: 3});
      expect(result.hasDuplicates, isTrue);
    });

    test('keeps different configIds as separate lines', () {
      final result = mergeDuplicateCartItems(<CartItem>[
        item(id: 1, configId: 'red', quantity: 1),
        item(id: 2, configId: 'blue', quantity: 1),
      ]);

      expect(result.items, hasLength(2));
      expect(result.extraLineIdsToDelete, isEmpty);
      expect(result.quantityUpdates, isEmpty);
      expect(result.hasDuplicates, isFalse);
    });

    test('treats empty and zero configId as the same base variant', () {
      final result = mergeDuplicateCartItems(<CartItem>[
        item(id: 5, configId: null, quantity: 1),
        item(id: 6, configId: '', quantity: 1),
        item(id: 7, configId: '0', quantity: 2),
      ]);

      expect(result.items, hasLength(1));
      expect(result.items.single.id, 5);
      expect(result.items.single.quantity, 4);
      expect(result.extraLineIdsToDelete, <int>[6, 7]);
    });

    test('merges product ids with and without cp- prefix', () {
      final result = mergeDuplicateCartItems(<CartItem>[
        item(id: 1, productId: '2085', quantity: 1),
        item(id: 2, productId: 'cp-2085', quantity: 1),
      ]);

      expect(result.items, hasLength(1));
      expect(result.items.single.quantity, 2);
      expect(result.extraLineIdsToDelete, <int>[2]);
    });

    test('returns original list when no duplicates', () {
      final result = mergeDuplicateCartItems(<CartItem>[
        item(id: 1, productId: 'a'),
        item(id: 2, productId: 'b'),
      ]);

      expect(result.items, hasLength(2));
      expect(result.hasDuplicates, isFalse);
    });
  });
}
