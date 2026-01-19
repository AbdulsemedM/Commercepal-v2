import 'product.dart';

class ProductSearchResponse {
  final List<Product> products;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  ProductSearchResponse({
    required this.products,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>? ?? 
                    json['products'] as List<dynamic>? ?? 
                    json['data'] as List<dynamic>? ?? 
                    <dynamic>[];
    
    final products = content
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    final pageable = json['pageable'] as Map<String, dynamic>?;
    final pageNumber = pageable?['pageNumber'] as int? ?? 
                       json['page'] as int? ?? 
                       json['currentPage'] as int? ?? 0;
    
    final pageSize = pageable?['pageSize'] as int? ?? 
                     json['size'] as int? ?? 
                     json['pageSize'] as int? ?? 36;

    final totalElements = json['totalElements'] as int? ?? 
                          json['total'] as int? ?? 
                          products.length;
    
    final totalPages = json['totalPages'] as int? ?? 
                       (totalElements / pageSize).ceil();

    return ProductSearchResponse(
      products: products,
      totalElements: totalElements,
      totalPages: totalPages,
      currentPage: pageNumber,
      size: pageSize,
      hasNext: json['hasNext'] as bool? ?? pageNumber < totalPages - 1,
      hasPrevious: json['hasPrevious'] as bool? ?? pageNumber > 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': products.map((p) => p.toJson()).toList(),
      'totalElements': totalElements,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'size': size,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
    };
  }
}
