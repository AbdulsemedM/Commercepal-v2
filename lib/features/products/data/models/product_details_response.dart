import 'product_details.dart';

class ProductDetailsResponse {
  final int status;
  final String message;
  final ProductDetails data;

  ProductDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: ProductDetails.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}
