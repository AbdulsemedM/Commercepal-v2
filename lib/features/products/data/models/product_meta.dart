class ProductMeta {
  final double rating;
  final int reviewCount;

  ProductMeta({
    required this.rating,
    required this.reviewCount,
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
