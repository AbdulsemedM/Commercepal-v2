class ProductImage {
  final String thumbnail;
  final String main;

  ProductImage({
    required this.thumbnail,
    required this.main,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      thumbnail: json['thumbnail'] as String? ?? '',
      main: json['main'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'main': main,
    };
  }
}
