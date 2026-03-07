import 'package:commercepal/features/products/data/models/product.dart';

/// Pagination info for wishlist (and other paginated APIs).
class WishlistPagination {
  const WishlistPagination({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  factory WishlistPagination.fromJson(Map<String, dynamic> json) {
    return WishlistPagination(
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );
  }
}

/// Response from GET /api/v1/wishlist?page=...
class WishlistResponse {
  const WishlistResponse({
    required this.pagination,
    required this.items,
  });

  final WishlistPagination pagination;
  final List<Product> items;

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final paginationJson = data['pagination'] as Map<String, dynamic>?;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];

    final pagination = paginationJson != null
        ? WishlistPagination.fromJson(paginationJson)
        : const WishlistPagination(
            page: 0,
            size: 20,
            totalElements: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
          );

    final items = itemsJson
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    return WishlistResponse(pagination: pagination, items: items);
  }
}
