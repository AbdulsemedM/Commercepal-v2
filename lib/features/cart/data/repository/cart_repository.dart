import '../data_provider/cart_data_provider.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/auth_service.dart';
import '../data_provider/local_cart_data_provider.dart';

import 'package:commercepal/features/products/data/models/product.dart';

class CartRepository {
  CartRepository({
    CartDataProvider? dataProvider,
    LocalCartDataProvider? localDataProvider,
    AuthService? authService,
  })  : _dataProvider = dataProvider ?? CartDataProvider(),
        _localDataProvider = localDataProvider ?? LocalCartDataProvider(),
        _authService = authService ?? AuthService();

  final CartDataProvider _dataProvider; // ignore: unused_field
  final LocalCartDataProvider _localDataProvider;
  final AuthService _authService;

  Future<Cart> addToCart(AddToCartRequest request, {Product? product}) async {
    AddToCartRequest resolvedRequest = request;
    if (_authService.isLoggedIn) {
      final storage = Storage();
      final country = await storage.getSelectedCountry();
      final currency = await storage.getSelectedCurrency();
      resolvedRequest = AddToCartRequest(
        items: [
          for (final item in request.items)
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

    return _localDataProvider.addToCart(resolvedRequest, product: product);

    // TODO: re-enable remote cart
    // if (_authService.isLoggedIn) {
    //   final cart = await _dataProvider.addToCart(resolvedRequest);
    //   await _localDataProvider.saveCart(cart);
    //   return cart;
    // }
    // return await _localDataProvider.addToCart(resolvedRequest, product: product);
  }

  Future<Cart> getCart() async {
    return _localDataProvider.getCart();

    // TODO: re-enable remote cart
    // if (_authService.isLoggedIn) {
    //   return await _dataProvider.getCart();
    // }
    // return await _localDataProvider.getCart();
  }

  Future<Cart> updateCartItem(int itemId, UpdateCartItemRequest request) async {
    return _localDataProvider.updateCartItem(itemId, request);

    // TODO: re-enable remote cart
    // if (_authService.isLoggedIn) {
    //   final cart = await _dataProvider.updateCartItem(itemId, request);
    //   await _localDataProvider.saveCart(cart);
    //   return cart;
    // }
    // return await _localDataProvider.updateCartItem(itemId, request);
  }

  Future<Cart> deleteCartItem(int itemId) async {
    return _localDataProvider.deleteCartItem(itemId);

    // TODO: re-enable remote cart
    // if (_authService.isLoggedIn) {
    //   final cart = await _dataProvider.deleteCartItem(itemId);
    //   await _localDataProvider.saveCart(cart);
    //   return cart;
    // }
    // return await _localDataProvider.deleteCartItem(itemId);
  }

  Future<ClearCartResponse> clearCart() async {
    return _localDataProvider.clearCart();

    // TODO: re-enable remote cart
    // if (_authService.isLoggedIn) {
    //   final response = await _dataProvider.clearCart();
    //   await _localDataProvider.clearCart();
    //   return response;
    // }
    // return await _localDataProvider.clearCart();
  }

  Future<void> syncLocalCartToRemote() async {
    AppLogger.i('Remote cart sync skipped (local-only cart mode)');

    // TODO: re-enable remote cart sync
    // final localCart = await _localDataProvider.getCart();
    //
    // if (localCart.items.isNotEmpty) {
    //   final storage = Storage();
    //   final savedCountry = await storage.getSelectedCountry();
    //   final savedCurrency = await storage.getSelectedCurrency();
    //
    //   AppLogger.i(
    //     "Syncing ${localCart.items.length} local cart items to backend",
    //   );
    //
    //   for (final item in localCart.items) {
    //     final request = AddToCartRequest(
    //       items: [
    //         AddToCartItem(
    //           productId: item.productId,
    //           configId: item.configId ?? "0",
    //           quantity: item.quantity,
    //           currency: savedCurrency,
    //           country: savedCountry,
    //         ),
    //       ],
    //     );
    //     await _dataProvider.addToCart(request);
    //   }
    //
    //   AppLogger.i("Successfully uploaded local cart items to backend");
    // }
    //
    // final mergedCart = await _dataProvider.getCart();
    // AppLogger.i(
    //   "Fetched merged cart with ${mergedCart.items.length} items from backend",
    // );
    // await _localDataProvider.saveCart(mergedCart);
    // AppLogger.i("Saved merged cart locally");
  }
}
