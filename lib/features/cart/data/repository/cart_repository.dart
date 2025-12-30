import '../data_provider/cart_data_provider.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';

class CartRepository {
  CartRepository({CartDataProvider? dataProvider})
    : _dataProvider = dataProvider ?? CartDataProvider();

  final CartDataProvider _dataProvider;

  Future<Cart> addToCart(AddToCartRequest request) async {
    return await _dataProvider.addToCart(request);
  }

  Future<Cart> getCart() async {
    return await _dataProvider.getCart();
  }

  Future<Cart> updateCartItem(int itemId, UpdateCartItemRequest request) async {
    return await _dataProvider.updateCartItem(itemId, request);
  }

  Future<Cart> deleteCartItem(int itemId) async {
    return await _dataProvider.deleteCartItem(itemId);
  }

  Future<ClearCartResponse> clearCart() async {
    return await _dataProvider.clearCart();
  }
}

