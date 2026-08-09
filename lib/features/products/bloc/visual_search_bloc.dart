import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/core/auth/session_error.dart';
import '../data/models/product.dart';
import '../data/repository/visual_search_repository.dart';

part 'visual_search_event.dart';
part 'visual_search_state.dart';

enum _VisualSearchMode { image, url }

class VisualSearchBloc extends Bloc<VisualSearchEvent, VisualSearchState> {
  VisualSearchBloc({VisualSearchRepository? repository})
      : _repository = repository ?? VisualSearchRepository(),
        super(VisualSearchInitial()) {
    on<VisualSearchReset>(_onReset);
    on<VisualSearchByImageRequested>(_onSearchByImage);
    on<VisualSearchByUrlRequested>(_onSearchByUrl);
    on<VisualSearchLoadMoreRequested>(_onLoadMore);
  }

  final VisualSearchRepository _repository;
  _VisualSearchMode? _mode;
  String? _imageBase64;
  String? _url;
  bool _loadMoreInProgress = false;

  static bool _isUnauthorized(Object e) => isUnauthorizedError(e);

  void _onReset(
    VisualSearchReset event,
    Emitter<VisualSearchState> emit,
  ) {
    _mode = null;
    _imageBase64 = null;
    _url = null;
    _loadMoreInProgress = false;
    emit(VisualSearchInitial());
  }

  Future<void> _onSearchByImage(
    VisualSearchByImageRequested event,
    Emitter<VisualSearchState> emit,
  ) async {
    _mode = _VisualSearchMode.image;
    _imageBase64 = event.imageBase64;
    _url = null;
    _loadMoreInProgress = false;
    emit(VisualSearchLoading());

    try {
      final result = await _repository.searchByImage(
        imageBase64: event.imageBase64,
      );
      emit(
        VisualSearchLoaded(
          products: result.products,
          message: result.message,
          hasMore: result.hasNext,
          currentPage: result.currentPage,
          previewImageBase64: event.imageBase64,
        ),
      );
    } catch (e) {
      emit(_mapError(e));
    }
  }

  Future<void> _onSearchByUrl(
    VisualSearchByUrlRequested event,
    Emitter<VisualSearchState> emit,
  ) async {
    _mode = _VisualSearchMode.url;
    _url = event.url.trim();
    _imageBase64 = null;
    _loadMoreInProgress = false;
    emit(VisualSearchLoading());

    try {
      final result = await _repository.searchByUrl(url: _url!);
      emit(
        VisualSearchLoaded(
          products: result.products,
          message: result.message,
          hasMore: result.hasNext,
          currentPage: result.currentPage,
          sourceUrl: _url,
        ),
      );
    } catch (e) {
      emit(_mapError(e));
    }
  }

  Future<void> _onLoadMore(
    VisualSearchLoadMoreRequested event,
    Emitter<VisualSearchState> emit,
  ) async {
    if (state is! VisualSearchLoaded) return;
    final VisualSearchLoaded current = state as VisualSearchLoaded;
    if (!current.hasMore || _loadMoreInProgress) return;

    _loadMoreInProgress = true;
    emit(current.copyWith(isLoadingMore: true));

    try {
      final int nextPage = current.currentPage + 1;
      final result = _mode == _VisualSearchMode.image && _imageBase64 != null
          ? await _repository.searchByImage(
              imageBase64: _imageBase64!,
              page: nextPage,
            )
          : _mode == _VisualSearchMode.url && _url != null
              ? await _repository.searchByUrl(url: _url!, page: nextPage)
              : null;
      if (result == null) {
        emit(current.copyWith(isLoadingMore: false));
        _loadMoreInProgress = false;
        return;
      }

      emit(
        current.copyWith(
          products: <Product>[...current.products, ...result.products],
          hasMore: result.hasNext,
          currentPage: result.currentPage,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    } finally {
      _loadMoreInProgress = false;
    }
  }

  VisualSearchError _mapError(Object e) {
    if (_isUnauthorized(e)) {
      return VisualSearchError(
        'Session expired. Please login again.',
        localizationKey: 'checkout.sessionExpired',
      );
    }
    if (e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout)) {
      return VisualSearchError(
        'Network error',
        localizationKey: 'visualSearch.errorNetwork',
      );
    }
    return VisualSearchError(
      'Search failed',
      localizationKey: 'visualSearch.errorGeneric',
    );
  }
}
