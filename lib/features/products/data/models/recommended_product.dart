import 'package:commercepal/core/utils/json_utils.dart';

import 'pricing.dart';
import 'product_image.dart';
import 'product_meta.dart';

class RecommendedProduct {
  final String id;
  final String title;
  final String provider;
  final String status;
  final int stockLevel;
  final Pricing pricing;
  final ProductImage images;
  final ProductMeta meta;

  RecommendedProduct({
    required this.id,
    required this.title,
    required this.provider,
    required this.status,
    required this.stockLevel,
    required this.pricing,
    required this.images,
    required this.meta,
  });

  /// Returns null when required nested fields are missing/invalid so a single
  /// bad recommended item cannot fail the parent product details parse.
  static RecommendedProduct? tryFromJson(Map<String, dynamic> json) {
    try {
      final Map<String, dynamic>? pricingMap = JsonUtils.asMap(json['pricing']);
      final Map<String, dynamic>? imagesMap = JsonUtils.asMap(json['images']);
      final Map<String, dynamic>? metaMap = JsonUtils.asMap(json['meta']);
      if (pricingMap == null || imagesMap == null || metaMap == null) {
        return null;
      }
      return RecommendedProduct(
        id: JsonUtils.asString(json['id']),
        title: JsonUtils.asString(json['title']),
        provider: JsonUtils.asString(json['provider']),
        status: JsonUtils.asString(json['status']),
        stockLevel: JsonUtils.asIntOr(json['stockLevel'], 0),
        pricing: Pricing.fromJson(pricingMap),
        images: ProductImage.fromJson(imagesMap),
        meta: ProductMeta.fromJson(metaMap),
      );
    } catch (_) {
      return null;
    }
  }

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return tryFromJson(json) ??
        RecommendedProduct(
          id: JsonUtils.asString(json['id']),
          title: JsonUtils.asString(json['title']),
          provider: JsonUtils.asString(json['provider']),
          status: JsonUtils.asString(json['status']),
          stockLevel: JsonUtils.asIntOr(json['stockLevel'], 0),
          pricing: Pricing.fromJson(const <String, dynamic>{}),
          images: ProductImage.fromJson(const <String, dynamic>{}),
          meta: ProductMeta.fromJson(const <String, dynamic>{}),
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'status': status,
      'stockLevel': stockLevel,
      'pricing': pricing.toJson(),
      'images': images.toJson(),
      'meta': meta.toJson(),
    };
  }
}
