import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/features/home/data/home_discover_config.dart';
import 'package:commercepal/features/home/data/repository/home_discover_repository.dart';
import 'package:commercepal/features/products/data/models/product.dart';

part 'home_discover_event.dart';
part 'home_discover_state.dart';

class HomeDiscoverBloc extends Bloc<HomeDiscoverEvent, HomeDiscoverState> {
  HomeDiscoverBloc({HomeDiscoverRepository? repository})
      : _repository = repository ?? HomeDiscoverRepository(),
        super(HomeDiscoverInitial()) {
    on<FetchHomeDiscover>(_onFetchHomeDiscover);
  }

  final HomeDiscoverRepository _repository;

  bool _mapsEqual(Map<String, List<Product>> a, Map<String, List<Product>> b) {
    for (final config in kHomeDiscoverSections) {
      final la = a[config.id] ?? [];
      final lb = b[config.id] ?? [];
      if (la.length != lb.length) return false;
      for (var i = 0; i < la.length; i++) {
        if (la[i].id != lb[i].id) return false;
      }
    }
    return true;
  }

  bool _hasAnyProducts(Map<String, List<Product>> map) {
    for (final config in kHomeDiscoverSections) {
      if ((map[config.id] ?? []).isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _onFetchHomeDiscover(
    FetchHomeDiscover event,
    Emitter<HomeDiscoverState> emit,
  ) async {
    final cachedPayload = await _repository.getCachedPayload();
    final cached = cachedPayload?.data ?? {};
    if (_hasAnyProducts(cached)) {
      emit(
        HomeDiscoverLoaded(
          sections: cached,
          updatedAt: cachedPayload?.updatedAt,
        ),
      );
    } else {
      emit(HomeDiscoverLoading());
    }

    try {
      final fresh = await _repository.fetchFresh();
      await _repository.saveCachedPayload(
        HomeDiscoverCachePayload(
          data: fresh,
          updatedAt: DateTime.now(),
        ),
      );

      final previous = state is HomeDiscoverLoaded
          ? (state as HomeDiscoverLoaded).sections
          : <String, List<Product>>{};

      if (!_mapsEqual(previous, fresh)) {
        emit(
          HomeDiscoverLoaded(
            sections: fresh,
            updatedAt: DateTime.now(),
          ),
        );
      } else if (state is HomeDiscoverLoading) {
        emit(
          HomeDiscoverLoaded(
            sections: fresh,
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      if (state is HomeDiscoverLoaded) return;
      emit(HomeDiscoverError('Could not load curated products. Pull to refresh later.'));
    }
  }
}
