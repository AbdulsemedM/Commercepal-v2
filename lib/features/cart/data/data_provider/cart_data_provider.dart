import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';

/// Remote cart API client for `/api/v1/cart*`.
///
/// Guests are identified via `X-Session-Id`; logged-in users via `Authorization`
/// (both set by [AuthInterceptor]). Add-to-cart also sends `X-Country` and
/// `X-Currency` per the docs contract.
class CartDataProvider {
  CartDataProvider({ApiService? apiService, Storage? storage})
      : _apiService = apiService ?? ApiService(),
        _storage = storage ?? Storage();

  final ApiService _apiService;
  final Storage _storage;
  static const String _cartEndpoint = '/api/v1/cart';
  static const String _cartItemsEndpoint = '/api/v1/cart/items';

  Future<Map<String, String>> _cartLocaleHeaders() async {
    final String country = await _storage.getSelectedCountry();
    final String currency = await _storage.getSelectedCurrency();
    return <String, String>{
      'X-Country': country,
      'X-Currency': currency,
    };
  }

  Future<Cart> addToCart(AddToCartRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        _cartItemsEndpoint,
        data: request.toJson(),
        headers: await _cartLocaleHeaders(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final Map<String, dynamic>? data =
          response.data!['data'] as Map<String, dynamic>?;
      if (data != null && data.containsKey('cartId')) {
        return Cart.fromJson(data);
      }

      return getCart();
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        return _reconcileCartAfterAddFailure(e);
      }
      AppLogger.e('Add to cart failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during add to cart', error: e, stack: stack);
      rethrow;
    }
  }

  Future<Cart> _reconcileCartAfterAddFailure(DioException original) async {
    try {
      final cart = await getCart();
      AppLogger.i(
        'Add-to-cart response failed (500); reconciled with server cart '
        '(${cart.totalItems} items)',
      );
      return cart;
    } catch (_) {
      throw original;
    }
  }

  Future<Cart> getCart() async {
    try {
      final response =
          await _apiService.get<Map<String, dynamic>>(_cartEndpoint);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final Map<String, dynamic> responseData = response.data!;
      final Map<String, dynamic>? data =
          responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response structure: missing data field',
        );
      }

      return Cart.fromJson(data);
    } on DioException catch (e) {
      AppLogger.e('Get cart failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during get cart', error: e, stack: stack);
      rethrow;
    }
  }

  Future<Cart> updateCartItem(int itemId, UpdateCartItemRequest request) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '$_cartItemsEndpoint/$itemId',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final Map<String, dynamic>? data =
          response.data!['data'] as Map<String, dynamic>?;
      if (data != null && data.containsKey('cartId')) {
        return Cart.fromJson(data);
      }

      return getCart();
    } on DioException catch (e) {
      AppLogger.e('Update cart item failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during update cart item',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<Cart> deleteCartItem(int itemId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '$_cartItemsEndpoint/$itemId',
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final Map<String, dynamic>? data =
          response.data!['data'] as Map<String, dynamic>?;
      if (data != null && data.containsKey('cartId')) {
        return Cart.fromJson(data);
      }

      return getCart();
    } on DioException catch (e) {
      AppLogger.e('Delete cart item failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during delete cart item',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<ClearCartResponse> clearCart() async {
    try {
      final response =
          await _apiService.delete<Map<String, dynamic>>(_cartEndpoint);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      return ClearCartResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Clear cart failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during clear cart', error: e, stack: stack);
      rethrow;
    }
  }
}
