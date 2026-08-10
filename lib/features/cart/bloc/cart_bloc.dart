import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/core/auth/session_error.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/features/cart/data/models/add_to_cart_request.dart';
import 'package:commercepal/features/cart/data/models/cart.dart';
import 'package:commercepal/features/cart/data/models/clear_cart_response.dart';
import 'package:commercepal/features/cart/data/models/update_cart_item_request.dart';
import 'package:commercepal/features/cart/data/repository/cart_repository.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/navigation_service.dart';
import 'package:commercepal/features/products/data/models/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({CartRepository? repository, AuthService? authService})
      : _repository = repository ?? CartRepository(),
        _authService = authService ?? AuthService(),
        super(CartInitial()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartAddItemRequested>(_onCartAddItemRequested);
    on<CartUpdateItemRequested>(_onCartUpdateItemRequested);
    on<CartDeleteItemRequested>(_onCartDeleteItemRequested);
    on<CartClearRequested>(_onCartClearRequested);
    on<CartRefreshRequested>(_onCartRefreshRequested);
    on<CartSyncRequested>(_onCartSyncRequested);
    on<CartReset>(_onCartReset);

    _authService.addListener(_onAuthStatusChanged);
  }

  final CartRepository _repository;
  final AuthService _authService;
  bool _wasLoggedIn = false;

  @override
  Future<void> close() {
    _authService.removeListener(_onAuthStatusChanged);
    return super.close();
  }

  void _onAuthStatusChanged() {
    final isLoggedIn = _authService.isLoggedIn;
    if (isLoggedIn && !_wasLoggedIn) {
      // User just logged in
      add(CartSyncRequested());
    } else if (!isLoggedIn && _wasLoggedIn) {
      // User just logged out
      add(CartReset());
      add(CartLoadRequested()); // Load guest cart (empty or previous)
    }
    _wasLoggedIn = isLoggedIn;
  }

  Future<void> _onCartLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      final cart = await _repository.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      String errorMessage = 'Failed to load cart. Please try again.';

      if (e is Exception) {
        if (NavigationService.instance.handleSessionExpired(e) ||
            isUnauthorizedError(e)) {
          errorMessage = 'Session expired. Please login again.';
        }
      }

      emit(CartError(errorMessage));
    }
  }

  Future<void> _onCartAddItemRequested(
    CartAddItemRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      // Use product.id when available so we send the same canonical id the API
      // uses (sync path uses this too). A degraded catalog record can carry an
      // empty id, so fall back to the id the caller navigated with.
      final String? catalogId = event.product?.id;
      final productId = (catalogId != null && catalogId.isNotEmpty)
          ? catalogId
          : event.productId;
      final request = AddToCartRequest(
        items: [
          AddToCartItem(
            productId: productId,
            configId: event.configId,
            quantity: event.quantity,
            currency: event.currency,
            country: event.country,
          ),
        ],
      );

      final cart = await _repository.addToCart(request, product: event.product);
      emit(CartItemAdded(cart));
    } catch (e) {
      String errorMessage = 'Failed to add item to cart. Please try again.';

      if (e is Exception) {
        if (NavigationService.instance.handleSessionExpired(e) ||
            isUnauthorizedError(e)) {
          errorMessage = 'Session expired. Please login again.';
        } else if (e is DioException && e.response?.statusCode == 400) {
          errorMessage = _extractApiErrorMessage(e) ?? 'Invalid item information';
          AppLogger.e(
            'Add to cart 400',
            error: e,
            stack: e.stackTrace,
          );
        }
      }

      emit(CartError(errorMessage));
    }
  }

  /// Extracts message from API error response (e.g. {"message": "..."} or {"error": "..."}).
  static String? _extractApiErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? data['error'] as String?;
      if (message != null && message.isNotEmpty) return message;
      final errors = data['errors'];
      if (errors is Map) {
        final first = errors.values.isNotEmpty ? errors.values.first : null;
        if (first is String) return first;
        if (first is List && first.isNotEmpty && first.first is String) {
          return first.first as String;
        }
      }
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  Future<void> _onCartUpdateItemRequested(
    CartUpdateItemRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      final request = UpdateCartItemRequest(
        quantity: event.quantity,
        replaceConfigId: event.replaceConfigId,
      );

      final cart = await _repository.updateCartItem(event.itemId, request);
      emit(CartItemUpdated(cart));
    } catch (e) {
      String errorMessage = 'Failed to update cart item. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('400') || e.toString().contains('Bad Request')
            ? 'Invalid update information'
            : e.toString().contains('404') || e.toString().contains('Not Found')
            ? 'Cart item not found'
            : errorMessage;
      }

      emit(CartError(errorMessage));
    }
  }

  Future<void> _onCartDeleteItemRequested(
    CartDeleteItemRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      final cart = await _repository.deleteCartItem(event.itemId);
      emit(CartItemDeleted(cart));
    } catch (e) {
      String errorMessage = 'Failed to delete cart item. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('404') || e.toString().contains('Not Found')
            ? 'Cart item not found'
            : errorMessage;
      }

      emit(CartError(errorMessage));
    }
  }

  Future<void> _onCartClearRequested(
    CartClearRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      final response = await _repository.clearCart();
      emit(CartCleared(response));
      // After clearing, load empty cart
      final cart = await _repository.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      String errorMessage = 'Failed to clear cart. Please try again.';

      if (e is Exception) {
        if (NavigationService.instance.handleSessionExpired(e) ||
            isUnauthorizedError(e)) {
          errorMessage = 'Session expired. Please login again.';
        }
      }

      emit(CartError(errorMessage));
    }
  }

  Future<void> _onCartRefreshRequested(
    CartRefreshRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cart = await _repository.getCart();
      if (state is CartLoaded) {
        emit(CartLoaded(cart));
      } else {
        emit(CartLoaded(cart));
      }
    } catch (e) {
      // Don't emit error on refresh, just log it
      // The cart state remains unchanged
    }
  }

  Future<void> _onCartSyncRequested(
    CartSyncRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      await _repository.syncLocalCartToRemote();
      add(CartLoadRequested());
    } catch (e) {
      emit(CartError('Failed to sync cart'));
    }
  }

  void _onCartReset(CartReset event, Emitter<CartState> emit) {
    emit(CartInitial());
  }
}

