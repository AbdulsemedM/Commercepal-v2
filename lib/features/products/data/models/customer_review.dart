import 'package:commercepal/core/utils/json_utils.dart';

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
    final List<dynamic>? featuredList =
        JsonUtils.asList(json['featuredValues']);
    return CustomerReview(
      content: JsonUtils.asString(json['content']),
      // API may send rating as 4.5 (double); truncate to int stars.
      rating: JsonUtils.asIntOr(json['rating'], 0),
      configId: JsonUtils.asString(json['configId']),
      reviewedAt: JsonUtils.asString(json['reviewedAt']),
      images: JsonUtils.asStringList(json['images']),
      featuredValues: featuredList
              ?.whereType<Map>()
              .map(
                (Map item) => FeaturedValue.fromJson(
                  JsonUtils.asMap(item) ?? const <String, dynamic>{},
                ),
              )
              .toList() ??
          const <FeaturedValue>[],
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
