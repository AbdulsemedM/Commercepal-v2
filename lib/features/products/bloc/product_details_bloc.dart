import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
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

      if (response.status == 200) {
        emit(ProductDetailsLoaded(
          productDetails: response.data,
          selectedVariantIndex: 0,
        ));
      } else {
        emit(ProductDetailsError(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to load product details',
          errorCode: response.status.toString(),
        ));
      }
    } on DioException catch (e) {
      AppLogger.e(
        'Failed to fetch product details',
        error: e,
        stack: e.stackTrace,
      );

      String errorMessage = 'Failed to load product details';
      if (e.response?.statusCode == 404) {
        errorMessage = 'Product not found';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      emit(ProductDetailsError(
        message: errorMessage,
        errorCode: e.response?.statusCode?.toString(),
      ));
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error fetching product details',
        error: e,
        stack: stack,
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

      if (response.status == 200) {
        // Preserve selected variant index if possible
        int selectedIndex = 0;
        if (state is ProductDetailsLoaded) {
          final currentState = state as ProductDetailsLoaded;
          selectedIndex = currentState.selectedVariantIndex;
          
          // Validate index is still valid with new data
          if (selectedIndex >= response.data.variants.length) {
            selectedIndex = 0;
          }
        }

        emit(ProductDetailsLoaded(
          productDetails: response.data,
          selectedVariantIndex: selectedIndex,
        ));
      } else {
        emit(ProductDetailsError(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to refresh product details',
          errorCode: response.status.toString(),
        ));
      }
    } catch (e, stack) {
      AppLogger.e(
        'Failed to refresh product details',
        error: e,
        stack: stack,
      );

      emit(const ProductDetailsError(
        message: 'Failed to refresh product details',
      ));
    }
  }
}
