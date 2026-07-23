import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';

/// Remote cart API client for `/api/v1/cart*`.
///
/// Temporarily unused: [CartRepository] routes all cart operations through
/// [LocalCartDataProvider] only. Keep this class intact for future re-enable.
class CartDataProvider {
  CartDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _cartEndpoint = '/api/v1/cart';
  static const String _cartItemsEndpoint = '/api/v1/cart/items';

  Future<Cart> addToCart(AddToCartRequest request) async {
    // The API expects camelCase fields; keep the snake_case body only as a
    // fallback for older backend deployments.
    try {
      return await _addToCartWithBody(request.toJson());
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        try {
          return await _addToCartWithBody(request.toJsonSnakeCase());
        } on DioException catch (retryError) {
          if (retryError.response?.statusCode == 500) {
            return await _reconcileCartAfterAddFailure(retryError);
          }
          rethrow;
        }
      }
      if (e.response?.statusCode == 500) {
        return await _reconcileCartAfterAddFailure(e);
      }
      rethrow;
    }
  }

  /// The backend sometimes persists the added item but fails while
  /// serializing its own response (500 "Type definition error:
  /// LocalDateTime"). Fetch the authoritative cart so the UI reflects
  /// whatever actually happened server-side.
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

  Future<Cart> _addToCartWithBody(Map<String, dynamic> body) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        _cartItemsEndpoint,
        data: body,
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;

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
      AppLogger.e('Add to cart failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during add to cart', error: e, stack: stack);
      rethrow;
    }
  }

  Future<Cart> getCart() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(_cartEndpoint);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      // Extract data from nested response structure
      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;
      
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

      // Extract data from nested response structure
      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;
      
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
      AppLogger.e('Update cart item failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during update cart item', error: e, stack: stack);
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

      // Extract data from nested response structure
      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;
      
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
      AppLogger.e('Delete cart item failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during delete cart item', error: e, stack: stack);
      rethrow;
    }
  }

  Future<ClearCartResponse> clearCart() async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(_cartEndpoint);

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

