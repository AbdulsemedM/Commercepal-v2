class ClearCartResponse {
  final int status;
  final String message;
  final ClearCartData? data;

  ClearCartResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ClearCartResponse.fromJson(Map<String, dynamic> json) {
    return ClearCartResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'] != null
          ? ClearCartData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ClearCartData {
  final Pagination? pagination;
  final List<Map<String, dynamic>> items;

  ClearCartData({
    this.pagination,
    required this.items,
  });

  factory ClearCartData.fromJson(Map<String, dynamic> json) {
    return ClearCartData(
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [],
    );
  }
}

class Pagination {
  final int page;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  Pagination({
    required this.page,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      size: json['size'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }
}

