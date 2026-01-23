class ProductVideo {
  final String url;
  final String previewUrl;

  ProductVideo({
    required this.url,
    required this.previewUrl,
  });

  factory ProductVideo.fromJson(Map<String, dynamic> json) {
    return ProductVideo(
      url: json['url'] as String? ?? '',
      previewUrl: json['previewUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'previewUrl': previewUrl,
    };
  }
}
