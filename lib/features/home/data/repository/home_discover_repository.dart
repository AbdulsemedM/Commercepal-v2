import 'dart:convert';

import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/home/data/home_discover_config.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/products/data/repository/product_search_repository.dart';

/// Parallel product search for home discover rows + JSON cache (SWR).
class HomeDiscoverRepository {
  HomeDiscoverRepository({
    ProductSearchRepository? productSearchRepository,
    Storage? storage,
  })  : _productSearchRepository =
            productSearchRepository ?? ProductSearchRepository(),
        _storage = storage ?? Storage();

  final ProductSearchRepository _productSearchRepository;
  final Storage _storage;

  static const int _pageSize = 32;

  Future<HomeDiscoverCachePayload?> getCachedPayload() async {
    final raw = await _storage.getCachedHomeDiscover();
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final updatedAtStr = decoded['updatedAt'] as String?;
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      final map = <String, List<Product>>{};
      for (final config in kHomeDiscoverSections) {
        final list = data[config.id] as List<dynamic>?;
        if (list == null) continue;
        map[config.id] = list
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final updatedAt = updatedAtStr != null
          ? DateTime.tryParse(updatedAtStr)
          : null;
      return HomeDiscoverCachePayload(data: map, updatedAt: updatedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedPayload(HomeDiscoverCachePayload payload) async {
    final data = <String, dynamic>{};
    for (final config in kHomeDiscoverSections) {
      final products = payload.data[config.id];
      if (products == null) continue;
      data[config.id] = products.map((p) => p.toJson()).toList();
    }
    final envelope = <String, dynamic>{
      'updatedAt': (payload.updatedAt ?? DateTime.now()).toIso8601String(),
      'data': data,
    };
    await _storage.saveCachedHomeDiscover(jsonEncode(envelope));
  }

  /// Fetches all sections in parallel. Failed sections get an empty list.
  Future<Map<String, List<Product>>> fetchFresh() async {
    final futures = kHomeDiscoverSections.map((config) async {
      try {
        final response = await _productSearchRepository.searchProducts(
          ProductSearchRequest(
            query: config.searchQuery,
            page: 0,
            size: _pageSize,
          ),
        );
        return MapEntry(config.id, response.products);
      } catch (_) {
        return MapEntry(config.id, <Product>[]);
      }
    });
    final entries = await Future.wait(futures);
    return Map.fromEntries(entries);
  }
}

class HomeDiscoverCachePayload {
  HomeDiscoverCachePayload({
    required this.data,
    this.updatedAt,
  });

  final Map<String, List<Product>> data;
  final DateTime? updatedAt;
}
