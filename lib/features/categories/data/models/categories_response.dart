import 'category.dart';

class CategoriesResponse {
  final int status;
  final String message;
  final List<Category> data;

  CategoriesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as List<dynamic>? ?? [];
    final categories = dataJson
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();

    return CategoriesResponse(
      status: json['status'] as int? ?? 200,
      message: json['message'] as String? ?? 'Success',
      data: categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((category) => category.toJson()).toList(),
    };
  }
}
