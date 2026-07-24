import 'dart:convert';

import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/home/data/home_wholesale_config.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/products/data/repository/product_search_repository.dart';

class HomeWholesaleRepository {
  HomeWholesaleRepository({
    ProductSearchRepository? productSearchRepository,
    Storage? storage,
  })  : _productSearchRepository =
            productSearchRepository ?? ProductSearchRepository(),
        _storage = storage ?? Storage();

  final ProductSearchRepository _productSearchRepository;
  final Storage _storage;

  Future<HomeWholesaleCachePayload?> getCachedPayload() async {
    final raw = await _storage.getCachedHomeWholesale();
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final updatedAtStr = decoded['updatedAt'] as String?;
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      final map = <String, List<Product>>{};
      for (final config in kHomeWholesaleSections) {
        final list = data[config.id] as List<dynamic>?;
        if (list == null) continue;
        map[config.id] = list
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final updatedAt =
          updatedAtStr != null ? DateTime.tryParse(updatedAtStr) : null;
      return HomeWholesaleCachePayload(data: map, updatedAt: updatedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedPayload(HomeWholesaleCachePayload payload) async {
    final data = <String, dynamic>{};
    for (final config in kHomeWholesaleSections) {
      final products = payload.data[config.id];
      if (products == null) continue;
      data[config.id] = products.map((p) => p.toJson()).toList();
    }
    final envelope = <String, dynamic>{
      'updatedAt': (payload.updatedAt ?? DateTime.now()).toIso8601String(),
      'data': data,
    };
    await _storage.saveCachedHomeWholesale(jsonEncode(envelope));
  }

  Future<Map<String, List<Product>>> fetchFresh() async {
    final futures = kHomeWholesaleSections.map((config) async {
      try {
        final products = await _fetchSection(config);
        return MapEntry(config.id, products);
      } catch (_) {
        return MapEntry(config.id, <Product>[]);
      }
    });
    final entries = await Future.wait(futures);
    return Map.fromEntries(entries);
  }

  Future<List<Product>> _fetchSection(HomeWholesaleSectionConfig config) async {
    try {
      final response = await _productSearchRepository.searchProducts(
        ProductSearchRequest(
          query: config.searchQuery,
          page: 0,
          size: config.pageSize,
          accountType: config.accountType,
        ),
      );
      return response.products;
    } catch (_) {
      return <Product>[];
    }
  }
}

class HomeWholesaleCachePayload {
  HomeWholesaleCachePayload({
    required this.data,
    this.updatedAt,
  });

  final Map<String, List<Product>> data;
  final DateTime? updatedAt;
}
