import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/features/products/data/models/product.dart';
import '../data/repository/recently_viewed_repository.dart';

part 'recently_viewed_event.dart';
part 'recently_viewed_state.dart';

class RecentlyViewedBloc extends Bloc<RecentlyViewedEvent, RecentlyViewedState> {
  RecentlyViewedBloc({RecentlyViewedRepository? repository})
      : _repository = repository ?? RecentlyViewedRepository(),
        super(RecentlyViewedInitial()) {
    on<FetchRecentlyViewed>(_onFetchRecentlyViewed);
  }

  final RecentlyViewedRepository _repository;

  bool _productsEqual(List<Product> a, List<Product> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> _onFetchRecentlyViewed(
    FetchRecentlyViewed event,
    Emitter<RecentlyViewedState> emit,
  ) async {
    // Step 1: Show cached data immediately if available (no loading spinner).
    final cached = await _repository.getCachedRecentlyViewed();
    if (cached.isNotEmpty) {
      emit(RecentlyViewedLoaded(products: cached));
    } else {
      emit(RecentlyViewedLoading());
    }

    // Step 2: Fetch fresh data in the background.
    try {
      final fresh = await _repository.getRecentlyViewed();

      // Update cache unconditionally.
      await _repository.saveCachedRecentlyViewed(fresh);

      // Only emit if data actually changed or we had no cache.
      if (!_productsEqual(cached, fresh)) {
        emit(RecentlyViewedLoaded(products: fresh));
      }
    } catch (e) {
      // If cached data is already on screen, stay silent on error.
      if (state is RecentlyViewedLoaded) return;

      emit(RecentlyViewedError('Failed to load recently viewed.'));
    }
  }
}
