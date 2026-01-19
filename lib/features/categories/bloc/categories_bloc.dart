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

  Future<void> _onFetchCategories(
    FetchCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());

    try {
      final response = await _repository.getCategories();
      
      // Sort categories by displayOrder and sort subcategories within each category
      final sortedCategories = response.data.map((category) {
        // Sort subcategories by displayOrder
        final sortedSubCategories = List<SubCategory>.from(category.subCategories)
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        
        // Create a new category with sorted subcategories
        return Category(
          id: category.id,
          name: category.name,
          slug: category.slug,
          code: category.code,
          description: category.description,
          imageUrl: category.imageUrl,
          displayOrder: category.displayOrder,
          providerId: category.providerId,
          subCategories: sortedSubCategories,
        );
      }).toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      
      emit(CategoriesLoaded(categories: sortedCategories));
    } catch (e) {
      String errorMessage = 'Failed to fetch categories. Please try again.';

      if (e is Exception) {
        errorMessage = e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : e.toString().contains('404') || e.toString().contains('Not Found')
                ? 'No categories found.'
                : errorMessage;
      }

      emit(CategoriesError(message: errorMessage));
    }
  }
}
