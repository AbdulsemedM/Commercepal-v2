import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/models/product.dart';
import '../data/models/product_search_request.dart';
// import '../data/models/product_search_response.dart';
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
  }

  final ProductSearchRepository _repository;
  ProductSearchRequest? _currentRequest;
  List<Product> _allProducts = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _loadMoreInProgress = false;

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
      String errorMessage = 'Failed to search products. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : e.toString().contains('404') || e.toString().contains('Not Found')
            ? 'No products found.'
            : errorMessage;
      }

      emit(ProductSearchError(errorMessage));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductSearchState> emit,
  ) async {
    if (!_hasMore || _currentRequest == null || _loadMoreInProgress) {
      return;
    }

    final currentState = state;
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
      final nextPage = _currentPage + 1;
      final request = _currentRequest!.copyWith(page: nextPage);

      final response = await _repository.searchProducts(request);

      _allProducts.addAll(response.products);
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
      String errorMessage = 'Failed to load more products. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : errorMessage;
      }

      emit(ProductSearchError(errorMessage));
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

    _loadMoreInProgress = false;
    emit(ProductSearchLoading());

    try {
      _currentPage = 0;
      _allProducts = [];
      _hasMore = true;

      _currentRequest = _currentRequest!.copyWith(
        page: 0,
        categoryId: event.categoryId ?? _currentRequest!.categoryId,
        provider: event.provider ?? _currentRequest!.provider,
        orderBy: event.orderBy ?? _currentRequest!.orderBy,
        brandId: event.brandId ?? _currentRequest!.brandId,
        isTmall: event.isTmall ?? _currentRequest!.isTmall,
        useOptimalFrameSize:
            event.useOptimalFrameSize ?? _currentRequest!.useOptimalFrameSize,
        maxVolume: event.maxVolume ?? _currentRequest!.maxVolume,
        minVolume: event.minVolume ?? _currentRequest!.minVolume,
        minPrice: event.minPrice ?? _currentRequest!.minPrice,
        maxPrice: event.maxPrice ?? _currentRequest!.maxPrice,
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
      String errorMessage = 'Failed to apply filters. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : errorMessage;
      }

      emit(ProductSearchError(errorMessage));
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
