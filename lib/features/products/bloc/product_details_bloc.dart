import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import '../data/repository/product_details_repository.dart';
import 'product_details_event.dart';
import 'product_details_state.dart';

class ProductDetailsBloc extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  ProductDetailsBloc({
    ProductDetailsRepository? repository,
  })  : _repository = repository ?? ProductDetailsRepository(),
        super(const ProductDetailsInitial()) {
    on<ProductDetailsFetchRequested>(_onFetchRequested);
    on<ProductDetailsVariantSelected>(_onVariantSelected);
    on<ProductDetailsRefreshRequested>(_onRefreshRequested);
  }

  final ProductDetailsRepository _repository;

  Future<void> _onFetchRequested(
    ProductDetailsFetchRequested event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(const ProductDetailsLoading());

    try {
      final response = await _repository.getProductDetails(
        event.productId,
        country: event.country,
        currency: event.currency,
      );

      if (response.status == 200 && response.data != null) {
        emit(ProductDetailsLoaded(
          productDetails: response.data!,
          selectedVariantIndex: 0,
        ));
      } else {
        emit(ProductDetailsError(
          message: response.message.isNotEmpty
              ? response.message
              : (response.data == null
                  ? 'Product details were incomplete'
                  : 'Failed to load product details'),
          errorCode: response.status.toString(),
        ));
      }
    } on DioException catch (e) {
      AppLogger.e(
        'Failed to fetch product details',
        error: e,
        stack: e.stackTrace,
      );

      final String? apiMessage = _extractApiMessage(e.response?.data);
      final String? apiErrorCode = _extractApiErrorCode(e.response?.data);
      final int? statusCode = e.response?.statusCode;

      String errorMessage = apiMessage ?? 'Failed to load product details';
      if (apiMessage == null) {
        if (statusCode == 404) {
          errorMessage = 'Product not found';
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Connection timeout. Please try again.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'No internet connection';
        } else if (statusCode == 503) {
          errorMessage =
              'This product is temporarily unavailable. Please try again shortly.';
        }
      }

      emit(ProductDetailsError(
        message: errorMessage,
        errorCode: apiErrorCode ?? statusCode?.toString(),
      ));
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error fetching product details',
        error: e,
        stack: stack,
      );
      await _recordPdpCrashlytics(
        error: e,
        stack: stack,
        productId: event.productId,
        reason: 'pdp_unexpected_fetch_error',
      );

      emit(const ProductDetailsError(
        message: 'An unexpected error occurred',
      ));
    }
  }

  Future<void> _onVariantSelected(
    ProductDetailsVariantSelected event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state is ProductDetailsLoaded) {
      final currentState = state as ProductDetailsLoaded;

      // Validate variant index
      if (event.variantIndex >= 0 &&
          event.variantIndex < currentState.productDetails.variants.length) {
        emit(currentState.copyWith(
          selectedVariantIndex: event.variantIndex,
        ));
      }
    }
  }

  Future<void> _onRefreshRequested(
    ProductDetailsRefreshRequested event,
    Emitter<ProductDetailsState> emit,
  ) async {
    // Don't show loading state for refresh, keep current data visible
    try {
      final response = await _repository.getProductDetails(
        event.productId,
        country: event.country,
        currency: event.currency,
      );

      if (response.status == 200 && response.data != null) {
        // Preserve selected variant index if possible
        int selectedIndex = 0;
        if (state is ProductDetailsLoaded) {
          final currentState = state as ProductDetailsLoaded;
          selectedIndex = currentState.selectedVariantIndex;

          // Validate index is still valid with new data
          if (selectedIndex >= response.data!.variants.length) {
            selectedIndex = 0;
          }
        }

        emit(ProductDetailsLoaded(
          productDetails: response.data!,
          selectedVariantIndex: selectedIndex,
        ));
      } else {
        emit(ProductDetailsError(
          message: response.message.isNotEmpty
              ? response.message
              : (response.data == null
                  ? 'Product details were incomplete'
                  : 'Failed to refresh product details'),
          errorCode: response.status.toString(),
        ));
      }
    } catch (e, stack) {
      AppLogger.e(
        'Failed to refresh product details',
        error: e,
        stack: stack,
      );
      await _recordPdpCrashlytics(
        error: e,
        stack: stack,
        productId: event.productId,
        reason: 'pdp_unexpected_refresh_error',
      );

      emit(const ProductDetailsError(
        message: 'Failed to refresh product details',
      ));
    }
  }

  /// Non-fatal Crashlytics events tagged for iOS PDP triage.
  /// Filter in console by reason `pdp_unexpected_*` or custom key `screen=product_details`.
  Future<void> _recordPdpCrashlytics({
    required Object error,
    required StackTrace stack,
    required String productId,
    required String reason,
  }) async {
    try {
      final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCustomKey('screen', 'product_details');
      await crashlytics.setCustomKey('productId', productId);
      await crashlytics.setCustomKey(
        'errorType',
        error.runtimeType.toString(),
      );
      await crashlytics.recordError(
        error,
        stack,
        fatal: false,
        reason: reason,
      );
    } catch (_) {
      // Crashlytics may be unavailable (e.g. before Firebase init / web).
    }
  }

  String? _extractApiMessage(dynamic data) {
    if (data is Map) {
      final Object? message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }

  String? _extractApiErrorCode(dynamic data) {
    if (data is Map) {
      final Object? code = data['errorCode'];
      if (code is String && code.trim().isNotEmpty) {
        return code.trim();
      }
    }
    return null;
  }
}
