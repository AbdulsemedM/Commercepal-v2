import '../data_provider/cart_data_provider.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/storage/storage.dart';
import '../data_provider/local_cart_data_provider.dart';
import '../../utils/cart_item_merge.dart';

import 'package:commercepal/features/products/data/models/product.dart';

class CartRepository {
  CartRepository({
    CartDataProvider? dataProvider,
    LocalCartDataProvider? localDataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? CartDataProvider(),
        _localDataProvider = localDataProvider ?? LocalCartDataProvider(),
        _storage = storage ?? Storage();

  final CartDataProvider _dataProvider;
  final LocalCartDataProvider _localDataProvider;
  final Storage _storage;

  Future<AddToCartRequest> _withLocale(AddToCartRequest request) async {
    final String country = await _storage.getSelectedCountry();
    final String currency = await _storage.getSelectedCurrency();
    return AddToCartRequest(
      items: [
        for (final AddToCartItem item in request.items)
          AddToCartItem(
            productId: item.productId,
            configId: item.configId,
            quantity: item.quantity,
            currency: currency,
            country: country,
          ),
      ],
    );
  }

  Future<Cart> _mirrorRemoteCart(Cart cart) async {
    await _localDataProvider.saveCart(cart);
    return cart;
  }

  /// Merges duplicate product+variant lines on the server, then mirrors locally.
  Future<Cart> _reconcileAndMirror(Cart cart) async {
    final CartItemMergeResult merge = mergeDuplicateCartItems(cart.items);
    if (!merge.hasDuplicates) {
      return _mirrorRemoteCart(cart);
    }

    AppLogger.i(
      'Reconciling ${merge.extraLineIdsToDelete.length} duplicate cart line(s)',
    );

    try {
      Cart latest = cart;

      // Update kept line quantities first while extras still exist.
      // Deleting first can empty the cart on the API (null cartId response).
      for (final MapEntry<int, int> entry in merge.quantityUpdates.entries) {
        latest = await _dataProvider.updateCartItem(
          entry.key,
          UpdateCartItemRequest(quantity: entry.value),
        );
      }

      for (final int extraId in merge.extraLineIdsToDelete) {
        latest = await _dataProvider.deleteCartItem(extraId);
      }

      // Re-check in case the server still returned duplicates after reconcile.
      final CartItemMergeResult after = mergeDuplicateCartItems(latest.items);
      if (after.hasDuplicates) {
        latest = cartWithMergedItems(latest, after.items);
      }

      return _mirrorRemoteCart(latest);
    } catch (e) {
      AppLogger.w(
        'Cart duplicate reconcile failed; falling back to client merge',
        data: e,
      );
      try {
        final Cart refreshed = await _dataProvider.getCart();
        final CartItemMergeResult after =
            mergeDuplicateCartItems(refreshed.items);
        if (after.hasDuplicates) {
          return _mirrorRemoteCart(
            cartWithMergedItems(refreshed, after.items),
          );
        }
        return _mirrorRemoteCart(refreshed);
      } catch (_) {
        return _mirrorRemoteCart(cartWithMergedItems(cart, merge.items));
      }
    }
  }

  Future<Cart> addToCart(AddToCartRequest request, {Product? product}) async {
    final AddToCartRequest resolvedRequest = await _withLocale(request);
    try {
      final Cart cart = await _dataProvider.addToCart(resolvedRequest);
      return _reconcileAndMirror(cart);
    } catch (e) {
      if (product != null) {
        AppLogger.w(
          'Remote add-to-cart failed; falling back to local cache',
          data: e,
        );
        return _localDataProvider.addToCart(resolvedRequest, product: product);
      }
      rethrow;
    }
  }

  Future<Cart> getCart() async {
    try {
      final Cart cart = await _dataProvider.getCart();
      return _reconcileAndMirror(cart);
    } catch (e) {
      AppLogger.w('Remote get-cart failed; using local cache', data: e);
      final Cart local = await _localDataProvider.getCart();
      final CartItemMergeResult merge = mergeDuplicateCartItems(local.items);
      if (!merge.hasDuplicates) return local;
      final Cart merged = cartWithMergedItems(local, merge.items);
      await _localDataProvider.saveCart(merged);
      return merged;
    }
  }

  Future<Cart> updateCartItem(int itemId, UpdateCartItemRequest request) async {
    try {
      final Cart cart = await _dataProvider.updateCartItem(itemId, request);
      return _reconcileAndMirror(cart);
    } catch (e) {
      AppLogger.w(
        'Remote update-cart-item failed; using local cache',
        data: e,
      );
      return _localDataProvider.updateCartItem(itemId, request);
    }
  }

  Future<Cart> deleteCartItem(int itemId) async {
    try {
      final Cart cart = await _dataProvider.deleteCartItem(itemId);
      return _reconcileAndMirror(cart);
    } catch (e) {
      AppLogger.w(
        'Remote delete-cart-item failed; using local cache',
        data: e,
      );
      return _localDataProvider.deleteCartItem(itemId);
    }
  }

  Future<ClearCartResponse> clearCart() async {
    try {
      final ClearCartResponse response = await _dataProvider.clearCart();
      await _localDataProvider.clearCart();
      return response;
    } catch (e) {
      AppLogger.w('Remote clear-cart failed; clearing local cache', data: e);
      return _localDataProvider.clearCart();
    }
  }

  /// After login, merge any offline local items then fetch the authoritative cart.
  Future<void> syncLocalCartToRemote() async {
    final Cart localCart = await _localDataProvider.getCart();

    if (localCart.items.isNotEmpty) {
      final String savedCountry = await _storage.getSelectedCountry();
      final String savedCurrency = await _storage.getSelectedCurrency();

      AppLogger.i(
        'Syncing ${localCart.items.length} local cart items to backend',
      );

      for (final item in localCart.items) {
        final AddToCartRequest request = AddToCartRequest(
          items: [
            AddToCartItem(
              productId: item.productId,
              configId: item.configId ?? '0',
              quantity: item.quantity,
              currency: savedCurrency,
              country: savedCountry,
            ),
          ],
        );
        await _dataProvider.addToCart(request);
      }

      AppLogger.i('Successfully uploaded local cart items to backend');
    }

    final Cart mergedCart = await _dataProvider.getCart();
    AppLogger.i(
      'Fetched merged cart with ${mergedCart.items.length} items from backend',
    );
    await _reconcileAndMirror(mergedCart);
    AppLogger.i('Saved merged cart locally');
  }
}
