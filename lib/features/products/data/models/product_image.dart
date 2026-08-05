import 'package:commercepal/core/utils/json_utils.dart';

class ProductImage {
  final String thumbnail;
  final String main;

  ProductImage({
    required this.thumbnail,
    required this.main,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      thumbnail: JsonUtils.asString(json['thumbnail']),
      main: JsonUtils.asString(json['main']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'main': main,
    };
  }
}
