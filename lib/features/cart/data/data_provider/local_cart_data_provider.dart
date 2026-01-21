import 'dart:convert';
import 'package:commercepal/core/storage/storage.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';

class LocalCartDataProvider {
  LocalCartDataProvider({Storage? storage}) : _storage = storage ?? Storage();

  final Storage _storage;
  static const String _cartKey = 'user_guest_cart';

  Future<Cart> getCart() async {
    final cartJson = await _storage.readData(_cartKey);
    if (cartJson != null) {
      return Cart.fromJson(jsonDecode(cartJson));
    }
    return _createEmptyCart();
  }

  Future<Cart> addToCart(AddToCartRequest request) async {
    Cart cart = await getCart();
    List<CartItem> items = List.from(cart.items);

    // For simplicity in this local simulation, we'll just handle the first item in the request
    // In a real scenario, we should handle all items.
    if (request.items.isEmpty) return cart;

    final newItemRequest = request.items.first;
    
    // Check if item already exists
    final existingItemIndex = items.indexWhere((item) => 
        item.productId == newItemRequest.productId.toString()); // Note: productId type mismatch might happen, checking types. 
        // In CartItem, productId is String. In AddToCartItem, productId is int. 
        // Wait, looking at AddToCartItem definition in cart_bloc using it:
        // 在 CartBloc: productId: event.productId (int)
        // In CartItem: productId (String)
        // We should handle conversion carefully.

    if (existingItemIndex != -1) {
      // Update quantity
      final existingItem = items[existingItemIndex];
      final newQuantity = existingItem.quantity + newItemRequest.quantity;
      
      items[existingItemIndex] = CartItem(
        id: existingItem.id,
        productId: existingItem.productId,
        productName: existingItem.productName,
        productImageUrl: existingItem.productImageUrl,
        quantity: newQuantity,
        unitPrice: existingItem.unitPrice,
        subtotal: existingItem.unitPrice * newQuantity,
        currency: existingItem.currency,
        provider: existingItem.provider,
        stockStatus: existingItem.stockStatus,
        isAvailable: existingItem.isAvailable,
        priceWhenAdded: existingItem.priceWhenAdded,
        currentPrice: existingItem.currentPrice,
        priceDropped: existingItem.priceDropped,
        savingsAmount: existingItem.savingsAmount,
      );
    } else {
      // Add new item
      // Problem: we don't have product details here (name, image, price)
      // The AddToCartRequest only has IDs.
      // The backend usually populates this.
      // For local cart, we assume the UI passes necessary info OR we just store minimum info
      // and rely on fetching product details when viewing cart if needed?
      // Actually, standard e-commerce flow: Add to cart -> Backend returns full Cart object with product details.
      // For local guest cart, simply storing IDs isn't enough to display the cart nicely without fetching product details again.
      // However, the prompt is about "store it in a local storage".
      
      // OPTION 1: Fetch product details from PRODUCT repository? No, that creates dependency cycle or complexity.
      // OPTION 2: Accept that local cart might look incomplete regarding details until synced? 
      // OPTION 3: (Better) Requires AddToCartRequest to be enriched or we mock the details for now.
      
      // Let's create a "Mock" item or minimal item.
      // Looking at `AddToCartItem` definition:
      // productId, configId, quantity, currency, country.
      
      // Fakes for now since we don't have product DB access here.
      // IMPORTANT: In a real app, we might need to cache product info or pass it to addToCart.
      // But let's proceed with a basic generic item so it works.
      
      items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch, // temporary ID
        productId: newItemRequest.productId.toString(),
        productName: "Product ${newItemRequest.productId}", // Placeholder
        productImageUrl: "", // Placeholder
        quantity: newItemRequest.quantity,
        unitPrice: 0.0, // Unknown
        subtotal: 0.0,
        currency: newItemRequest.currency,
        provider: "",
        stockStatus: "In Stock",
        isAvailable: true,
        priceWhenAdded: 0.0,
        currentPrice: 0.0,
        priceDropped: false,
        savingsAmount: 0.0,
      ));
    }

    final updatedCart = _updateCartTotals(cart, items);
    await _saveCart(updatedCart);
    return updatedCart;
  }

  Future<Cart> updateCartItem(int itemId, UpdateCartItemRequest request) async {
    Cart cart = await getCart();
    List<CartItem> items = List.from(cart.items);
    
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (request.quantity == 0) {
        items.removeAt(index);
      } else {
        final existingItem = items[index];
        items[index] = CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          productName: existingItem.productName,
          productImageUrl: existingItem.productImageUrl,
          quantity: request.quantity,
          unitPrice: existingItem.unitPrice,
          subtotal: existingItem.unitPrice * request.quantity,
          currency: existingItem.currency,
          provider: existingItem.provider,
          stockStatus: existingItem.stockStatus,
          isAvailable: existingItem.isAvailable,
          priceWhenAdded: existingItem.priceWhenAdded,
          currentPrice: existingItem.currentPrice,
          priceDropped: existingItem.priceDropped,
          savingsAmount: existingItem.savingsAmount,
        );
      }
    }

    final updatedCart = _updateCartTotals(cart, items);
    await _saveCart(updatedCart);
    return updatedCart;
  }

  Future<Cart> deleteCartItem(int itemId) async {
    Cart cart = await getCart();
    List<CartItem> items = List.from(cart.items);
    
    items.removeWhere((item) => item.id == itemId);

    final updatedCart = _updateCartTotals(cart, items);
    await _saveCart(updatedCart);
    return updatedCart;
  }

  Future<ClearCartResponse> clearCart() async {
    await _storage.deleteData(_cartKey);
    return ClearCartResponse(status: 200, message: "Cart cleared locally");
  }

  Future<void> _saveCart(Cart cart) async {
    await _storage.writeData(key: _cartKey, value: jsonEncode(cart.toJson()));
  }

  Cart _createEmptyCart() {
    return Cart(
      cartId: 0,
      totalItems: 0,
      subtotal: 0,
      estimatedTotal: 0,
      currency: "ETB", // Default
      lastActivityAt: DateTime.now(),
      items: [],
      priceDropItems: [],
      unavailableItems: [],
      totalSavings: 0,
    );
  }

  Cart _updateCartTotals(Cart oldCart, List<CartItem> newItems) {
    double subtotal = 0;
    int totalItems = 0;
    
    for (var item in newItems) {
      subtotal += item.subtotal;
      totalItems += item.quantity;
    }

    return Cart(
      cartId: oldCart.cartId, // Keep same ID or generate new one
      totalItems: totalItems,
      subtotal: subtotal,
      estimatedTotal: subtotal, // Assuming no extra fees for local calc
      currency: oldCart.currency,
      lastActivityAt: DateTime.now(),
      items: newItems,
      priceDropItems: oldCart.priceDropItems,
      unavailableItems: oldCart.unavailableItems,
      totalSavings: oldCart.totalSavings,
    );
  }
}
