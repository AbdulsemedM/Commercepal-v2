import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/cart/data/models/cart.dart';
import 'package:flutter_test/flutter_test.dart';

Cart _cart(int items) => Cart(
      cartId: 1,
      totalItems: items,
      subtotal: 0,
      estimatedTotal: 0,
      currency: 'ETB',
      lastActivityAt: DateTime(2026),
      items: const [],
      priceDropItems: const [],
      unavailableItems: const [],
      totalSavings: 0,
    );

void main() {
  test('cartOrNull returns the cart for every cart-carrying state', () {
    final Cart c = _cart(3);
    expect(CartLoaded(c).cartOrNull, c);
    expect(CartItemAdded(c).cartOrNull, c);
    expect(CartItemUpdated(c).cartOrNull, c);
    expect(CartItemDeleted(c).cartOrNull, c);
    expect(CartLoading().cartOrNull, isNull);
    expect(CartError('x').cartOrNull, isNull);
    expect(CartInitial().cartOrNull, isNull);
  });
}
