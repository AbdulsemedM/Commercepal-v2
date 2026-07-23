import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/features/home/data/home_wholesale_config.dart';
import 'package:commercepal/features/home/data/repository/home_wholesale_repository.dart';
import 'package:commercepal/features/products/data/models/product.dart';

part 'home_wholesale_event.dart';
part 'home_wholesale_state.dart';

class HomeWholesaleBloc extends Bloc<HomeWholesaleEvent, HomeWholesaleState> {
  HomeWholesaleBloc({HomeWholesaleRepository? repository})
      : _repository = repository ?? HomeWholesaleRepository(),
        super(HomeWholesaleInitial()) {
    on<FetchHomeWholesale>(_onFetchHomeWholesale);
  }

  final HomeWholesaleRepository _repository;

  bool _mapsEqual(Map<String, List<Product>> a, Map<String, List<Product>> b) {
    for (final config in kHomeWholesaleSections) {
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
    for (final config in kHomeWholesaleSections) {
      if ((map[config.id] ?? []).isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _onFetchHomeWholesale(
    FetchHomeWholesale event,
    Emitter<HomeWholesaleState> emit,
  ) async {
    final cachedPayload = await _repository.getCachedPayload();
    final cached = cachedPayload?.data ?? {};
    if (_hasAnyProducts(cached)) {
      emit(
        HomeWholesaleLoaded(
          sections: cached,
          updatedAt: cachedPayload?.updatedAt,
        ),
      );
    } else {
      emit(HomeWholesaleLoading());
    }

    try {
      final fresh = await _repository.fetchFresh();
      await _repository.saveCachedPayload(
        HomeWholesaleCachePayload(
          data: fresh,
          updatedAt: DateTime.now(),
        ),
      );

      final previous = state is HomeWholesaleLoaded
          ? (state as HomeWholesaleLoaded).sections
          : <String, List<Product>>{};

      if (!_mapsEqual(previous, fresh)) {
        emit(
          HomeWholesaleLoaded(
            sections: fresh,
            updatedAt: DateTime.now(),
          ),
        );
      } else if (state is HomeWholesaleLoading) {
        emit(
          HomeWholesaleLoaded(
            sections: fresh,
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (_) {
      if (state is HomeWholesaleLoaded) return;
      emit(
        HomeWholesaleError(
          'Could not load wholesale products. Pull to refresh later.',
        ),
      );
    }
  }
}
