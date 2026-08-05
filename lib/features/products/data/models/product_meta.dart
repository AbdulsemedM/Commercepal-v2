import 'package:commercepal/core/utils/json_utils.dart';

class ProductMeta {
  final double rating;
  final int reviewCount;

  ProductMeta({
    required this.rating,
    required this.reviewCount,
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      rating: JsonUtils.asDoubleOr(json['rating'], 0.0),
      reviewCount: JsonUtils.asIntOr(json['reviewCount'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
