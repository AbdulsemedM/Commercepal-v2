import 'package:commercepal/core/utils/json_utils.dart';

import 'product_details.dart';

class ProductDetailsResponse {
  final int status;
  final String message;
  final ProductDetails? data;

  ProductDetailsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? dataMap = JsonUtils.asMap(json['data']);
    return ProductDetailsResponse(
      status: JsonUtils.asIntOr(json['status'], 0),
      message: JsonUtils.asString(json['message']),
      data: dataMap != null ? ProductDetails.fromJson(dataMap) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}
