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

  /// Empty page (e.g. null body or unparseable payload treated as no results).
  factory ProductSearchResponse.empty({int currentPage = 0, int size = 20}) {
    return ProductSearchResponse(
      products: <Product>[],
      totalElements: 0,
      totalPages: 0,
      currentPage: currentPage,
      size: size,
      hasNext: false,
      hasPrevious: false,
    );
  }

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested structure: { data: { items: [...], pagination: {...} } }
    List<dynamic> content;
    Map<String, dynamic>? paginationData;
    
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      // Nested structure with data.items
      content = data['items'] as List<dynamic>? ?? <dynamic>[];
      paginationData = data['pagination'] as Map<String, dynamic>?;
    } else if (data is List) {
      // data is directly a list
      content = data;
      paginationData = null;
    } else {
      // Fallback to other possible locations
      content = json['content'] as List<dynamic>? ?? 
                json['products'] as List<dynamic>? ?? 
                <dynamic>[];
      paginationData = null;
    }
    
    final products = content
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    // Extract pagination info
    int pageNumber;
    int pageSize;
    bool hasNext;
    bool hasPrevious;
    
    if (paginationData != null) {
      // Use pagination object from data.pagination
      pageNumber = paginationData['page'] as int? ?? 0;
      pageSize = paginationData['size'] as int? ?? 36;
      hasNext = paginationData['hasNext'] as bool? ?? false;
      hasPrevious = paginationData['hasPrevious'] as bool? ?? false;
    } else {
      // Fallback to old logic
      final pageable = json['pageable'] as Map<String, dynamic>?;
      pageNumber = pageable?['pageNumber'] as int? ?? 
                   json['page'] as int? ?? 
                   json['currentPage'] as int? ?? 0;
      
      pageSize = pageable?['pageSize'] as int? ?? 
                 json['size'] as int? ?? 
                 json['pageSize'] as int? ?? 36;
      
      hasNext = json['hasNext'] as bool? ?? false;
      hasPrevious = json['hasPrevious'] as bool? ?? false;
    }

    final totalElements = json['totalElements'] as int? ?? 
                          json['total'] as int? ?? 
                          products.length;
    
    final totalPages = json['totalPages'] as int? ?? 
                       (pageSize > 0 ? (totalElements / pageSize).ceil() : 0);

    return ProductSearchResponse(
      products: products,
      totalElements: totalElements,
      totalPages: totalPages,
      currentPage: pageNumber,
      size: pageSize,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
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
