import '../data_provider/cart_data_provider.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';

import 'package:commercepal/core/logging/app_logger.dart';
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

  final CartDataProvider _dataProvider;
  final LocalCartDataProvider _localDataProvider;
  final AuthService _authService;

  Future<Cart> addToCart(AddToCartRequest request, {Product? product}) async {
    if (_authService.isLoggedIn) {
      return await _dataProvider.addToCart(request);
    } else {
      return await _localDataProvider.addToCart(request, product: product);
    }
  }

  Future<Cart> getCart() async {
    if (_authService.isLoggedIn) {
      // Sync happens in Bloc usually, but we can also ensure sync here if needed?
      // Better to keep simple: just fetch.
      return await _dataProvider.getCart();
    } else {
      return await _localDataProvider.getCart();
    }
  }

  Future<Cart> updateCartItem(int itemId, UpdateCartItemRequest request) async {
    if (_authService.isLoggedIn) {
      return await _dataProvider.updateCartItem(itemId, request);
    } else {
      return await _localDataProvider.updateCartItem(itemId, request);
    }
  }

  Future<Cart> deleteCartItem(int itemId) async {
    if (_authService.isLoggedIn) {
      return await _dataProvider.deleteCartItem(itemId);
    } else {
      return await _localDataProvider.deleteCartItem(itemId);
    }
  }

  Future<ClearCartResponse> clearCart() async {
    if (_authService.isLoggedIn) {
      return await _dataProvider.clearCart();
    } else {
      return await _localDataProvider.clearCart();
    }
  }

  Future<void> syncLocalCartToRemote() async {
    try {
      final localCart = await _localDataProvider.getCart();
      if (localCart.items.isNotEmpty) {
        for (final item in localCart.items) {
           // Create request for each item
           // Note: AddToCartRequest expects List<AddToCartItem>
           // AddToCartItem expects: productId (int), configId, quantity, etc.
           // However, CartItem has productId as String. 
           // We need to parse it. If it fails, we skip.
           
           if (item.productId == null) {
             AppLogger.e("Skipping sync for item with invalid ID");
             continue;
           }

           final request = AddToCartRequest(
             items: [
               AddToCartItem(
                 productId: item.productId,
                 configId: "0", // Default to "0" or empty if not available
                 quantity: item.quantity,
                 currency: item.currency,
                 country: "ET", // Default to ET or empty string if not available
               )
             ]
           );
           
           await _dataProvider.addToCart(request);
        }
        // Clear local cart after successful sync
        await _localDataProvider.clearCart();
      }
    } catch (e, s) {
      AppLogger.e("Failed to sync local cart", error: e, stack: s);
      // We don't rethrow, to not block the main flow.
    }
  }
}

