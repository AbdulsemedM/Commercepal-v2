import 'dart:convert';

import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/products/data/models/product.dart';

import '../data_provider/recently_viewed_data_provider.dart';

class RecentlyViewedRepository {
  RecentlyViewedRepository({
    RecentlyViewedDataProvider? dataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? RecentlyViewedDataProvider(),
        _storage = storage ?? Storage();

  final RecentlyViewedDataProvider _dataProvider;
  final Storage _storage;

  Future<List<Product>> getRecentlyViewed() async {
    final country = await _storage.getSelectedCountry();
    final currency = await _storage.getSelectedCurrency();
    return _dataProvider.getRecentlyViewed(
      country: country,
      currency: currency,
    );
  }

  Future<List<Product>> getCachedRecentlyViewed() async {
    final raw = await _storage.getCachedRecentlyViewed();
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCachedRecentlyViewed(List<Product> products) async {
    final json = jsonEncode(products.map((p) => p.toJson()).toList());
    await _storage.saveCachedRecentlyViewed(json);
  }
}
