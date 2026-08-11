import 'package:commercepal/features/products/data/models/product.dart';
import '../../utils/cart_product_id.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';
import 'cart_database_helper.dart';

/// Normalizes variant ids so base products match across '', '0', and null.
String? normalizeCartConfigId(String? configId) {
  final trimmed = configId?.trim() ?? '';
  if (trimmed.isEmpty || trimmed == '0') return null;
  return trimmed;
}

bool cartItemsMatchVariant(CartItem item, String productId, String? configId) {
  return normalizeCartProductId(item.productId) ==
          normalizeCartProductId(productId) &&
      normalizeCartConfigId(item.configId) == normalizeCartConfigId(configId);
}

/// Older builds could persist rows from a degraded catalog record (empty id,
/// zero price). They can never be checked out, so they are dropped on read.
bool isPurchasableCartItem(CartItem item) {
  return item.productId.trim().isNotEmpty && item.unitPrice > 0;
}

class LocalCartDataProvider {
  LocalCartDataProvider({CartDatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? CartDatabaseHelper();

  final CartDatabaseHelper _dbHelper;

  Future<Cart> getCart() async {
    final items = await _dbHelper.getItems();
    final purchasable = <CartItem>[];
    final invalidIds = <int>[];

    for (final item in items) {
      if (isPurchasableCartItem(item)) {
        purchasable.add(item);
      } else {
        invalidIds.add(item.id);
      }
    }

    for (final id in invalidIds) {
      await _dbHelper.deleteItem(id);
    }

    return await _createCartFromItems(purchasable);
  }

  Future<Cart> addToCart(AddToCartRequest request, {Product? product}) async {
    if (request.items.isEmpty) return getCart();

    final newItemRequest = request.items.first;
    final normalizedConfigId = normalizeCartConfigId(newItemRequest.configId);
    final items = await _dbHelper.getItems();
    final existingItemIndex = items.indexWhere(
      (item) => cartItemsMatchVariant(
        item,
        newItemRequest.productId.toString(),
        newItemRequest.configId,
      ),
    );

    if (existingItemIndex != -1) {
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
        configId: existingItem.configId ?? normalizedConfigId,
      );
      await _dbHelper.updateItem(updatedItem);
    } else {
      if (product == null) {
        throw Exception(
          'Product details are required to add items to the local cart.',
        );
      }

      final unitPrice = product.price;
      // Store the same id the lookup above matched on, otherwise a degraded
      // record with an empty product id would never dedupe against itself.
      final resolvedProductId = newItemRequest.productId.isNotEmpty
          ? newItemRequest.productId
          : product.id;
      final newItem = CartItem(
        id: 0,
        productId: resolvedProductId,
        productName: product.name,
        productImageUrl: product.imageUrl ?? '',
        quantity: newItemRequest.quantity,
        unitPrice: unitPrice,
        subtotal: unitPrice * newItemRequest.quantity,
        currency: product.currency.isNotEmpty
            ? product.currency
            : newItemRequest.currency,
        provider: product.provider ?? '',
        stockStatus: product.stockStatus ?? 'IN_STOCK',
        isAvailable: product.isAvailable ?? true,
        priceWhenAdded: unitPrice,
        currentPrice: unitPrice,
        priceDropped: false,
        savingsAmount: 0.0,
        configId: normalizedConfigId,
      );
      await _dbHelper.insertItem(newItem);
    }

    return getCart();
  }

  Future<Cart> updateCartItem(int itemId, UpdateCartItemRequest request) async {
    final items = await _dbHelper.getItems();
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
          configId: existingItem.configId ??
              normalizeCartConfigId(request.replaceConfigId),
        );
        await _dbHelper.updateItem(updatedItem);
      }
    }

    return getCart();
  }

  Future<Cart> deleteCartItem(int itemId) async {
    await _dbHelper.deleteItem(itemId);
    return getCart();
  }

  Future<ClearCartResponse> clearCart() async {
    await _dbHelper.clearCart();
    await _dbHelper.clearCartMeta();
    return ClearCartResponse(status: 200, message: 'Cart cleared locally');
  }

  /// Saves a complete cart from the backend to local storage
  /// Replaces all existing local cart items with items from the provided cart
  Future<void> saveCart(Cart cart) async {
    await _dbHelper.clearCart();
    await _dbHelper.setCartId(cart.cartId);

    for (final item in cart.items) {
      await _dbHelper.insertItem(item);
    }
  }

  Future<Cart> _createCartFromItems(List<CartItem> items) async {
    double subtotal = 0;
    int totalItems = 0;

    for (final item in items) {
      subtotal += item.subtotal;
      totalItems += item.quantity;
    }

    final cartId = await _dbHelper.getCartId();

    return Cart(
      cartId: cartId,
      totalItems: totalItems,
      subtotal: subtotal,
      estimatedTotal: subtotal,
      currency: items.isNotEmpty ? items.first.currency : 'ETB',
      lastActivityAt: DateTime.now(),
      items: items,
      priceDropItems: [],
      unavailableItems: [],
      totalSavings: 0,
    );
  }
}
