import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'package:commercepal/core/auth/session_error.dart';
import '../data/models/product.dart';
import '../data/models/product_search_request.dart';
import '../data/repository/product_search_repository.dart';

part 'product_search_event.dart';
part 'product_search_state.dart';

class ProductSearchBloc extends Bloc<ProductSearchEvent, ProductSearchState> {
  ProductSearchBloc({ProductSearchRepository? repository})
    : _repository = repository ?? ProductSearchRepository(),
      super(ProductSearchInitial()) {
    on<SearchProducts>(_onSearchProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<ApplyFilters>(_onApplyFilters);
    on<ResetSearch>(_onResetSearch);
    on<ClearSearchNotice>(_onClearSearchNotice);
  }

  final ProductSearchRepository _repository;
  ProductSearchRequest? _currentRequest;
  List<Product> _allProducts = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _loadMoreInProgress = false;

  static bool _isUnauthorized(Object e) => isUnauthorizedError(e);

  static bool _isNoResultsHttp(Object e) {
    if (e is! DioException) return false;
    final int? code = e.response?.statusCode;
    return code == 404 || code == 204;
  }

  static bool _isNetworkIssue(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.cancel;
  }

  void _onClearSearchNotice(
    ClearSearchNotice event,
    Emitter<ProductSearchState> emit,
  ) {
    if (state is! ProductSearchLoaded) return;
    final ProductSearchLoaded s = state as ProductSearchLoaded;
    if (s.noticeKey == null) return;
    emit(
      ProductSearchLoaded(
        products: s.products,
        totalElements: s.totalElements,
        totalPages: s.totalPages,
        currentPage: s.currentPage,
        hasMore: s.hasMore,
      ),
    );
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductSearchState> emit,
  ) async {
    _loadMoreInProgress = false;
    emit(ProductSearchLoading());

    try {
      _currentPage = 0;
      _allProducts = [];
      _hasMore = true;

      _currentRequest = event.request.copyWith(page: 0);

      final response = await _repository.searchProducts(_currentRequest!);

      _allProducts = response.products;
      _currentPage = response.currentPage;
      _hasMore = response.hasNext;

      emit(
        ProductSearchLoaded(
          products: _allProducts,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          currentPage: response.currentPage,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      if (_isUnauthorized(e)) {
        emit(
          ProductSearchError(
            'Session expired. Please login again.',
            localizationKey: 'checkout.sessionExpired',
          ),
        );
        return;
      }
      if (_isNoResultsHttp(e)) {
        _allProducts = <Product>[];
        _currentPage = 0;
        _hasMore = false;
        emit(
          ProductSearchLoaded(
            products: _allProducts,
            totalElements: 0,
            totalPages: 0,
            currentPage: 0,
            hasMore: false,
          ),
        );
        return;
      }
      if (e is DioException && _isNetworkIssue(e)) {
        emit(
          ProductSearchError(
            'Network error',
            localizationKey: 'productSearch.errorNetwork',
          ),
        );
        return;
      }
      emit(
        ProductSearchError(
          'Failed to search products. Please try again.',
          localizationKey: 'productSearch.errorGeneric',
        ),
      );
    }
  }

  /// Stop auto-paging after this many pages in a row add no new products.
  static const int maxEmptyPagesInARow = 3;

  /// Adds products not already shown; returns how many were new.
  int _appendUnique(List<Product> products) {
    final Set<String> seen = _allProducts.map((Product p) => p.id).toSet();
    int added = 0;
    for (final Product product in products) {
      if (product.id.isEmpty || seen.add(product.id)) {
        _allProducts.add(product);
        added++;
      }
    }
    return added;
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductSearchState> emit,
  ) async {
    if (!_hasMore || _currentRequest == null || _loadMoreInProgress) {
      return;
    }

    final ProductSearchState currentState = state;
    if (currentState is! ProductSearchLoaded) {
      return;
    }

    _loadMoreInProgress = true;
    emit(
      ProductSearchLoadingMore(
        products: _allProducts,
        totalElements: currentState.totalElements,
        totalPages: currentState.totalPages,
        currentPage: currentState.currentPage,
      ),
    );

    try {
      // A page can add nothing new (filtered or repeated cards) while the server still has
      // more. Fetch onward a few pages instead of stopping with an unfinished list.
      var response = await _repository.searchProducts(
        _currentRequest!.copyWith(page: _currentPage + 1),
      );
      int added = _appendUnique(response.products);
      int emptyPagesInARow = added == 0 ? 1 : 0;
      while (added == 0 &&
          response.hasNext &&
          emptyPagesInARow < maxEmptyPagesInARow) {
        response = await _repository.searchProducts(
          _currentRequest!.copyWith(page: response.currentPage + 1),
        );
        added = _appendUnique(response.products);
        emptyPagesInARow = added == 0 ? emptyPagesInARow + 1 : 0;
      }

      _currentPage = response.currentPage;
      _hasMore = response.hasNext && emptyPagesInARow < maxEmptyPagesInARow;

      emit(
        ProductSearchLoaded(
          products: _allProducts,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          currentPage: response.currentPage,
          hasMore: _hasMore,
        ),
      );
    } catch (e) {
      emit(
        ProductSearchLoaded(
          products: List<Product>.from(_allProducts),
          totalElements: currentState.totalElements,
          totalPages: currentState.totalPages,
          currentPage: currentState.currentPage,
          hasMore: _hasMore,
          noticeKey: 'productSearch.loadMoreFailed',
        ),
      );
    } finally {
      _loadMoreInProgress = false;
    }
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<ProductSearchState> emit,
  ) async {
    if (_currentRequest == null) {
      return;
    }

    final ProductSearchLoaded? previousLoaded =
        state is ProductSearchLoaded ? state as ProductSearchLoaded : null;
    final ProductSearchRequest previousRequest = _currentRequest!;

    _loadMoreInProgress = false;
    emit(ProductSearchLoading());

    try {
      _currentPage = 0;
      _allProducts = [];
      _hasMore = true;

      _currentRequest = previousRequest.copyWith(
        page: 0,
        categoryId: event.categoryId ?? previousRequest.categoryId,
        provider: event.provider ?? previousRequest.provider,
        orderBy: event.orderBy ?? previousRequest.orderBy,
        brandId: event.brandId ?? previousRequest.brandId,
        isTmall: event.isTmall ?? previousRequest.isTmall,
        useOptimalFrameSize:
            event.useOptimalFrameSize ?? previousRequest.useOptimalFrameSize,
        maxVolume: event.maxVolume ?? previousRequest.maxVolume,
        minVolume: event.minVolume ?? previousRequest.minVolume,
        minPrice: event.minPrice ?? previousRequest.minPrice,
        maxPrice: event.maxPrice ?? previousRequest.maxPrice,
      );

      final response = await _repository.searchProducts(_currentRequest!);

      _allProducts = response.products;
      _currentPage = response.currentPage;
      _hasMore = response.hasNext;

      emit(
        ProductSearchLoaded(
          products: _allProducts,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          currentPage: response.currentPage,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      _currentRequest = previousRequest;
      if (previousLoaded != null) {
        _allProducts = List<Product>.from(previousLoaded.products);
        _currentPage = previousLoaded.currentPage;
        _hasMore = previousLoaded.hasMore;
        emit(
          ProductSearchLoaded(
            products: _allProducts,
            totalElements: previousLoaded.totalElements,
            totalPages: previousLoaded.totalPages,
            currentPage: previousLoaded.currentPage,
            hasMore: previousLoaded.hasMore,
            noticeKey: 'productSearch.applyFiltersFailed',
          ),
        );
        return;
      }
      if (_isUnauthorized(e)) {
        emit(
          ProductSearchError(
            'Session expired. Please login again.',
            localizationKey: 'checkout.sessionExpired',
          ),
        );
        return;
      }
      if (e is DioException && _isNetworkIssue(e)) {
        emit(
          ProductSearchError(
            'Network error',
            localizationKey: 'productSearch.errorNetwork',
          ),
        );
        return;
      }
      emit(
        ProductSearchError(
          'Failed to apply filters. Please try again.',
          localizationKey: 'productSearch.errorApplyFilters',
        ),
      );
    }
  }

  void _onResetSearch(ResetSearch event, Emitter<ProductSearchState> emit) {
    _currentRequest = null;
    _allProducts = [];
    _currentPage = 0;
    _hasMore = true;
    _loadMoreInProgress = false;
    emit(ProductSearchInitial());
  }
}
