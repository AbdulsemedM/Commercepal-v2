import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/models/category.dart';
import '../data/models/sub_category.dart';
import '../data/repository/categories_repository.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc({CategoriesRepository? repository})
    : _repository = repository ?? CategoriesRepository(),
      super(CategoriesInitial()) {
    on<FetchCategories>(_onFetchCategories);
  }

  final CategoriesRepository _repository;

  List<Category> _sortCategories(List<Category> raw) {
    return raw.map((category) {
      final sortedSubs = List<SubCategory>.from(category.subCategories)
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return Category(
        id: category.id,
        name: category.name,
        slug: category.slug,
        code: category.code,
        description: category.description,
        imageUrl: category.imageUrl,
        displayOrder: category.displayOrder,
        providerId: category.providerId,
        subCategories: sortedSubs,
      );
    }).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  bool _categoriesEqual(List<Category> a, List<Category> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].name != b[i].name) return false;
    }
    return true;
  }

  Future<void> _onFetchCategories(
    FetchCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    // Step 1: Show cached data immediately if available (no loading spinner).
    final cached = await _repository.getCachedCategories();
    if (cached.isNotEmpty) {
      emit(CategoriesLoaded(categories: cached));
    } else {
      emit(CategoriesLoading());
    }

    // Step 2: Fetch fresh data in the background.
    try {
      final response = await _repository.getCategories();
      final fresh = _sortCategories(response.data);

      // Update cache unconditionally.
      await _repository.saveCachedCategories(fresh);

      // Only emit if data actually changed or we had no cache.
      final currentCached = cached;
      if (!_categoriesEqual(currentCached, fresh)) {
        emit(CategoriesLoaded(categories: fresh));
      }
    } catch (e) {
      // If we already have cached data on screen, stay silent on error.
      if (state is CategoriesLoaded) return;

      String errorMessage = 'Failed to fetch categories. Please try again.';
      if (e is Exception) {
        if (e.toString().contains('404') || e.toString().contains('Not Found')) {
          errorMessage = 'No categories found.';
        }
      }
      emit(CategoriesError(message: errorMessage));
    }
  }
}
