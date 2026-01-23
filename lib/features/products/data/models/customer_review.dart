import 'featured_value.dart';

class CustomerReview {
  final String content;
  final int rating;
  final String configId;
  final String reviewedAt;
  final List<String> images;
  final List<FeaturedValue> featuredValues;

  CustomerReview({
    required this.content,
    required this.rating,
    required this.configId,
    required this.reviewedAt,
    required this.images,
    required this.featuredValues,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      content: json['content'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      configId: json['configId'] as String? ?? '',
      reviewedAt: json['reviewedAt'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      featuredValues: (json['featuredValues'] as List<dynamic>?)
              ?.map((item) => FeaturedValue.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'rating': rating,
      'configId': configId,
      'reviewedAt': reviewedAt,
      'images': images,
      'featuredValues': featuredValues.map((fv) => fv.toJson()).toList(),
    };
  }
}
