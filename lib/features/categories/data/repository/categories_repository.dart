import '../data_provider/categories_data_provider.dart';
import '../models/categories_response.dart';
import '../models/sub_categories_response.dart';

class CategoriesRepository {
  CategoriesRepository({CategoriesDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? CategoriesDataProvider();

  final CategoriesDataProvider _dataProvider;

  Future<CategoriesResponse> getCategories() async {
    return await _dataProvider.getCategories();
  }

  Future<SubCategoriesResponse> getSubCategories(String categoryId) async {
    return await _dataProvider.getSubCategories(categoryId);
  }
}
