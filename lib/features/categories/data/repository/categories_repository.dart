import 'dart:convert';

import 'package:commercepal/core/storage/storage.dart';

import '../data_provider/categories_data_provider.dart';
import '../models/categories_response.dart';
import '../models/category.dart';
import '../models/category_subcategory_fallbacks.dart';
import '../models/sub_categories_response.dart';

class CategoriesRepository {
  CategoriesRepository({
    CategoriesDataProvider? dataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? CategoriesDataProvider(),
        _storage = storage ?? Storage();

  final CategoriesDataProvider _dataProvider;
  final Storage _storage;

  Future<CategoriesResponse> getCategories() async {
    final response = await _dataProvider.getCategories();
    return CategoriesResponse(
      status: response.status,
      message: response.message,
      data: CategorySubcategoryFallbacks.enrichAll(response.data),
    );
  }

  Future<SubCategoriesResponse> getSubCategories(String categoryId) async {
    return await _dataProvider.getSubCategories(categoryId);
  }

  Future<List<Category>> getCachedCategories() async {
    final raw = await _storage.getCachedCategories();
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final categories = list
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      // Re-enrich so older caches that predate this logic still meet the
      // minimum subcategory count.
      return CategorySubcategoryFallbacks.enrichAll(categories);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCachedCategories(List<Category> categories) async {
    final enriched = CategorySubcategoryFallbacks.enrichAll(categories);
    final json = jsonEncode(enriched.map((c) => c.toJson()).toList());
    await _storage.saveCachedCategories(json);
  }
}
