import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/network/auth_request_options.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/auth/refresh/data/repository/refresh_token_repository.dart';
import 'package:commercepal/services/api_service.dart';
import 'package:commercepal/services/auth_service.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart.dart';
import '../models/clear_cart_response.dart';
import '../models/update_cart_item_request.dart';

/// Remote cart API client for `/api/cart*`.
///
/// Guests are identified via `X-Session-Id`; logged-in users via `Authorization`
/// (both set by [AuthInterceptor]). Add-to-cart also sends `X-Country` and
/// `X-Currency` per the docs contract.
class CartDataProvider {
  CartDataProvider({
    ApiService? apiService,
    Storage? storage,
    RefreshTokenRepository? refreshTokenRepository,
    AuthService? authService,
  })  : _apiService = apiService ?? ApiService(),
        _storage = storage ?? Storage(),
        _refreshTokenRepository =
            refreshTokenRepository ?? RefreshTokenRepository(),
        _authService = authService ?? AuthService();

  final ApiService _apiService;
  final Storage _storage;
  final RefreshTokenRepository _refreshTokenRepository;
  final AuthService _authService;
  static const String _cartEndpoint = '/api/cart';
  static const String _cartItemsEndpoint = '/api/cart/items';
  static const String _cartMergeEndpoint = '/api/cart/merge';

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
      return await _runWithWebCartAuthFallback(
        () => _postAddToCart(request),
        () => _postAddToCart(
          request,
          extra: <String, dynamic>{
            kForceGuestSessionExtra: true,
            kIncludeGuestSessionExtra: true,
          },
        ),
      );
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

  /// Website cart 401 path: refresh once, retry auth, then drop tokens and
  /// finish as guest (`forceGuestSession`).
  Future<T> _runWithWebCartAuthFallback<T>(
    Future<T> Function() authenticated,
    Future<T> Function() asGuest,
  ) async {
    try {
      return await authenticated();
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;
    }

    final String? refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _refreshTokenRepository.refreshToken(refreshToken);
        return await authenticated();
      } on DioException catch (e) {
        if (e.response?.statusCode != 401) {
          AppLogger.w('Cart token refresh failed; continuing as guest', data: e);
        }
      } catch (e) {
        AppLogger.w('Cart token refresh failed; continuing as guest', data: e);
      }
    }

    AppLogger.w(
      'Cart rejected auth after refresh; dropping tokens and using guest session',
    );
    await _storage.clearAuthSession();
    _authService.invalidateSession();
    return asGuest();
  }

  Future<Cart> _postAddToCart(
    AddToCartRequest request, {
    Map<String, dynamic>? extra,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      _cartItemsEndpoint,
      data: request.toJson(),
      headers: await _cartLocaleHeaders(),
      extra: extra,
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
    if (data != null && data['cartId'] != null) {
      return Cart.fromJson(data);
    }

    return getCart();
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

  /// Merges the guest cart (identified by [guestCartId]) into the logged-in cart.
  /// Returns true when merge succeeded or was already applied (409/400).
  Future<bool> mergeGuestCart(String guestCartId) async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        _cartMergeEndpoint,
        data: <String, dynamic>{'guestCartId': guestCartId},
        extra: <String, dynamic>{kIncludeGuestSessionExtra: true},
      );
      return true;
    } on DioException catch (e) {
      final int? status = e.response?.statusCode;
      if (status == 409 || status == 400) {
        AppLogger.w(
          'Cart merge already applied or rejected (status $status)',
        );
        return true;
      }
      AppLogger.e('Cart merge failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during cart merge', error: e, stack: stack);
      rethrow;
    }
  }

  Future<Cart> getCart() async {
    try {
      return await _runWithWebCartAuthFallback(
        () => _fetchCart(),
        () => _fetchCart(forceGuest: true),
      );
    } on DioException catch (e) {
      AppLogger.e('Get cart failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during get cart', error: e, stack: stack);
      rethrow;
    }
  }

  Future<Cart> _fetchCart({bool forceGuest = false}) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      _cartEndpoint,
      extra: forceGuest
          ? <String, dynamic>{
              kForceGuestSessionExtra: true,
              kIncludeGuestSessionExtra: true,
            }
          : null,
    );

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
      if (data != null && data['cartId'] != null) {
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
      // DELETE may return cartId: null with an empty items list even when the
      // cart still exists — only trust a non-null cartId, otherwise re-fetch.
      if (data != null && data['cartId'] != null) {
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
