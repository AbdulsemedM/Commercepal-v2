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

  Future<void> _onFetchRecentlyViewed(
    FetchRecentlyViewed event,
    Emitter<RecentlyViewedState> emit,
  ) async {
    emit(RecentlyViewedLoading());

    try {
      final products = await _repository.getRecentlyViewed();
      emit(RecentlyViewedLoaded(products: products));
    } catch (e) {
      String message = 'Failed to load recently viewed.';
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        message = 'Please sign in to see recently viewed.';
      }
      emit(RecentlyViewedError(message));
    }
  }
}
