import 'package:commercepal/core/utils/json_utils.dart';

class ProductVideo {
  final String url;
  final String previewUrl;

  ProductVideo({
    required this.url,
    required this.previewUrl,
  });

  factory ProductVideo.fromJson(Map<String, dynamic> json) {
    return ProductVideo(
      url: JsonUtils.asString(json['url']),
      previewUrl: JsonUtils.asString(json['previewUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'previewUrl': previewUrl,
    };
  }
}
