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

  final CartDataProvider _dataProvider;
  final LocalCartDataProvider _localDataProvider;
  final AuthService _authService;

  Future<Cart> addToCart(AddToCartRequest request, {Product? product}) async {
    if (_authService.isLoggedIn) {
      final storage = Storage();
      final country = await storage.getSelectedCountry();
      final currency = await storage.getSelectedCurrency();
      final resolvedRequest = AddToCartRequest(
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
      return await _dataProvider.addToCart(resolvedRequest);
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
    // Get local cart items
    final localCart = await _localDataProvider.getCart();
    
    // Upload local items to backend if any exist
    if (localCart.items.isNotEmpty) {
      // Get saved country code from settings
      final storage = Storage();
      final savedCountry = await storage.getSelectedCountry();
      
      AppLogger.i("Syncing ${localCart.items.length} local cart items to backend");
      
      final savedCurrency = await storage.getSelectedCurrency();
      for (final item in localCart.items) {
         final request = AddToCartRequest(
           items: [
             AddToCartItem(
               productId: item.productId,
               configId: item.configId ?? "0",
               quantity: item.quantity,
               currency: savedCurrency,
               country: savedCountry,
             )
           ],
         );
         
         // Upload item to backend (let errors propagate)
         await _dataProvider.addToCart(request);
      }
      
      AppLogger.i("Successfully uploaded local cart items to backend");
    }
    
    // Fetch complete merged cart from backend (includes local + pre-existing items)
    final mergedCart = await _dataProvider.getCart();
    AppLogger.i("Fetched merged cart with ${mergedCart.items.length} items from backend");
    
    // Save merged cart locally for offline access
    await _localDataProvider.saveCart(mergedCart);
    AppLogger.i("Saved merged cart locally");
    
    // Note: No catch block - errors propagate to CartBloc for proper handling
  }
}

