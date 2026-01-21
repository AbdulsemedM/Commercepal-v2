import 'package:commercepal/features/products/data/models/product.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';
import 'cart_database_helper.dart';

class LocalCartDataProvider {
  LocalCartDataProvider({CartDatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? CartDatabaseHelper();

  final CartDatabaseHelper _dbHelper;

  Future<Cart> getCart() async {
    final items = await _dbHelper.getItems();
    return _createCartFromItems(items);
  }

  Future<Cart> addToCart(AddToCartRequest request, {Product? product}) async {
    if (request.items.isEmpty) return await getCart();

    final newItemRequest = request.items.first;
    // Check if item already exists
    final items = await _dbHelper.getItems();
    final existingItemIndex = items.indexWhere((item) => 
        item.productId == newItemRequest.productId.toString());

    if (existingItemIndex != -1) {
      // Update quantity
      final existingItem = items[existingItemIndex];
      final newQuantity = existingItem.quantity + newItemRequest.quantity;
      
      final updatedItem = CartItem(
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
      await _dbHelper.updateItem(updatedItem);
    } else {
      // Add new item
      if (product != null) {
        final newItem = CartItem(
          id: 0, // Auto-increment will handle this
          productId: product.id,
          productName: product.name,
          productImageUrl: product.imageUrl ?? '',
          quantity: newItemRequest.quantity,
          unitPrice: product.price,
          subtotal: product.price * newItemRequest.quantity,
          currency: product.currency,
          provider: product.provider ?? '',
          stockStatus: product.stockStatus ?? "In Stock",
          isAvailable: product.isAvailable ?? true,
          priceWhenAdded: product.price,
          currentPrice: product.price,
          priceDropped: false, // Default
          savingsAmount: 0.0, // Default
        );
        await _dbHelper.insertItem(newItem);
      } else {
         // Fallback if product not provided, though we expect it to be provided now.
         // We create a minimal item to avoid crashing, but it will lack details.
         final newItem = CartItem(
          id: 0,
          productId: newItemRequest.productId.toString(),
          productName: "Unknown Product",
          productImageUrl: "",
          quantity: newItemRequest.quantity,
          unitPrice: 0.0,
          subtotal: 0.0,
          currency: newItemRequest.currency,
          provider: "",
          stockStatus: "Unknown",
          isAvailable: true,
          priceWhenAdded: 0.0,
          currentPrice: 0.0,
          priceDropped: false,
          savingsAmount: 0.0,
        );
        await _dbHelper.insertItem(newItem);
      }
    }

    return await getCart();
  }

  Future<Cart> updateCartItem(int itemId, UpdateCartItemRequest request) async {
    // Determine if itemId refers to DB id or productId?
    // In CartItem, `id` is the DB key.
    // The request usually passes the ID from the Cart object.
    
    // We fetch the item by ID.
    final items = await _dbHelper.getItems();
    // Assuming itemId corresponds to CartItem.id
    final index = items.indexWhere((item) => item.id == itemId);

    if (index != -1) {
      if (request.quantity == 0) {
        await _dbHelper.deleteItem(itemId);
      } else {
        final existingItem = items[index];
        final updatedItem = CartItem(
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
        await _dbHelper.updateItem(updatedItem);
      }
    }
    
    return await getCart();
  }

  Future<Cart> deleteCartItem(int itemId) async {
    await _dbHelper.deleteItem(itemId);
    return await getCart();
  }

  Future<ClearCartResponse> clearCart() async {
    await _dbHelper.clearCart();
    return ClearCartResponse(status: 200, message: "Cart cleared locally");
  }

  Cart _createCartFromItems(List<CartItem> items) {
    double subtotal = 0;
    int totalItems = 0;
    
    for (var item in items) {
      subtotal += item.subtotal;
      totalItems += item.quantity;
    }

    return Cart(
      cartId: 0, // Local cart ID
      totalItems: totalItems,
      subtotal: subtotal,
      estimatedTotal: subtotal, 
      currency: items.isNotEmpty ? items.first.currency : "ETB",
      lastActivityAt: DateTime.now(),
      items: items,
      priceDropItems: [],
      unavailableItems: [],
      totalSavings: 0,
    );
  }
}
