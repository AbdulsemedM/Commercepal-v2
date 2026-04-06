import 'dart:convert';

import 'package:commercepal/core/storage/storage.dart';

import '../data_provider/categories_data_provider.dart';
import '../models/categories_response.dart';
import '../models/category.dart';
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
    return await _dataProvider.getCategories();
  }

  Future<SubCategoriesResponse> getSubCategories(String categoryId) async {
    return await _dataProvider.getSubCategories(categoryId);
  }

  Future<List<Category>> getCachedCategories() async {
    final raw = await _storage.getCachedCategories();
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCachedCategories(List<Category> categories) async {
    final json = jsonEncode(categories.map((c) => c.toJson()).toList());
    await _storage.saveCachedCategories(json);
  }
}
