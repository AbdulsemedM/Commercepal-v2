import 'sub_category.dart';

class SubCategoriesResponse {
  final int status;
  final String message;
  final List<SubCategory> data;

  SubCategoriesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SubCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as List<dynamic>? ?? [];
    final subCategories = dataJson
        .map((item) => SubCategory.fromJson(item as Map<String, dynamic>))
        .toList();

    return SubCategoriesResponse(
      status: json['status'] as int? ?? 200,
      message: json['message'] as String? ?? 'Success',
      data: subCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((subCategory) => subCategory.toJson()).toList(),
    };
  }
}
