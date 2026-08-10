import 'package:commercepal/features/cart/data/models/add_to_cart_request.dart';
import 'package:commercepal/features/cart/data/models/cart.dart';
import 'package:commercepal/features/cart/data/models/cart_item.dart';
import 'package:commercepal/features/cart/utils/cart_product_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeCartProductId', () {
    test('adds cp- prefix when missing', () {
      expect(normalizeCartProductId('2085245075104260097'), 'cp-2085245075104260097');
    });

    test('keeps existing cp- prefix', () {
      expect(
        normalizeCartProductId('cp-2085245075104260097'),
        'cp-2085245075104260097',
      );
    });
  });

  group('AddToCartItem', () {
    test('serializes docs cart body without locale fields', () {
      final item = AddToCartItem(
        productId: '2085245075104260097',
        configId: 'variant-1',
        quantity: 2,
        currency: 'ETB',
        country: 'ET',
      );

      expect(item.toJson(), <String, dynamic>{
        'productId': 'cp-2085245075104260097',
        'configId': 'variant-1',
        'quantity': 2,
      });
    });
  });

  group('Cart.fromJson docs shape', () {
    test('parses nested totals and pricing', () {
      final cart = Cart.fromJson(<String, dynamic>{
        'cartId': 123,
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 456,
            'productId': 'cp-2085245075104260097',
            'configId': 'variant-1',
            'quantity': 1,
            'pricing': <String, dynamic>{
              'unitPrice': 2636.0,
              'totalPrice': 2636.0,
            },
          },
        ],
        'totals': <String, dynamic>{
          'subtotal': 2636.0,
          'total': 2636.0,
          'currency': 'ETB',
        },
      });

      expect(cart.cartId, 123);
      expect(cart.currency, 'ETB');
      expect(cart.subtotal, 2636.0);
      expect(cart.estimatedTotal, 2636.0);
      expect(cart.totalItems, 1);
      expect(cart.items.single.id, 456);
      expect(cart.items.single.unitPrice, 2636.0);
      expect(cart.items.single.subtotal, 2636.0);
    });
  });

  group('CartItem.fromJson docs shape', () {
    test('uses productId as fallback name', () {
      final item = CartItem.fromJson(<String, dynamic>{
        'id': 1,
        'productId': 'cp-abc',
        'quantity': 2,
        'pricing': <String, dynamic>{
          'unitPrice': 10,
          'totalPrice': 20,
        },
      });

      expect(item.productName, 'cp-abc');
      expect(item.subtotal, 20);
    });
  });
}
