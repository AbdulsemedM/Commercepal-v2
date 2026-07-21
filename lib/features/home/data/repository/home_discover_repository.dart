import 'dart:convert';

import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/home/data/home_discover_config.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/products/data/repository/product_search_repository.dart';

/// Parallel product search for home discover rows + JSON cache (SWR).
///
/// Multi-query sections follow commercepal.com: fetch each query in parallel,
/// dedupe by product id, stop once [pageSize] unique items are collected.
class HomeDiscoverRepository {
  HomeDiscoverRepository({
    ProductSearchRepository? productSearchRepository,
    Storage? storage,
  })  : _productSearchRepository =
            productSearchRepository ?? ProductSearchRepository(),
        _storage = storage ?? Storage();

  final ProductSearchRepository _productSearchRepository;
  final Storage _storage;

  static const int _pageSize = 20;

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
        final products = await _fetchSection(config);
        return MapEntry(config.id, products);
      } catch (_) {
        return MapEntry(config.id, <Product>[]);
      }
    });
    final entries = await Future.wait(futures);
    return Map.fromEntries(entries);
  }

  Future<List<Product>> _fetchSection(HomeDiscoverSectionConfig config) async {
    final queries = config.allQueries;
    if (queries.length == 1) {
      return _search(queries.first, _pageSize);
    }

    // Mirror web merge: pull a slice from each query in parallel, dedupe by id.
    final perQuery = (_pageSize / queries.length).ceil().clamp(4, _pageSize);
    final results = await Future.wait(
      queries.map((q) => _search(q, perQuery)),
    );

    final seen = <String>{};
    final merged = <Product>[];
    for (final batch in results) {
      for (final product in batch) {
        if (!seen.add(product.id)) continue;
        merged.add(product);
        if (merged.length >= _pageSize) return merged;
      }
    }

    // Top up from remaining queries if still short (same as web fallback pass).
    if (merged.length < _pageSize) {
      for (final q in queries) {
        if (merged.length >= _pageSize) break;
        final more = await _search(q, _pageSize - merged.length);
        for (final product in more) {
          if (!seen.add(product.id)) continue;
          merged.add(product);
          if (merged.length >= _pageSize) break;
        }
      }
    }

    return merged;
  }

  Future<List<Product>> _search(String query, int size) async {
    try {
      final response = await _productSearchRepository.searchProducts(
        ProductSearchRequest(
          query: query,
          page: 0,
          size: size,
        ),
      );
      return response.products;
    } catch (_) {
      return <Product>[];
    }
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
