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

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      status: json['status'] as String? ?? '',
      stockLevel: json['stockLevel'] as int? ?? 0,
      pricing: Pricing.fromJson(
        json['pricing'] as Map<String, dynamic>,
      ),
      images: ProductImage.fromJson(
        json['images'] as Map<String, dynamic>,
      ),
      meta: ProductMeta.fromJson(
        json['meta'] as Map<String, dynamic>,
      ),
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
