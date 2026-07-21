import 'physical_parameters.dart';
import 'pricing.dart';
import 'product_image.dart';
import 'product_video.dart';
import 'variant.dart';
import 'product_meta.dart';
import 'customer_review.dart';
import 'recommended_product.dart';

class ProductDetails {
  final String id;
  final String title;
  final String provider;
  final String brandName;
  final String vendorName;
  final String categoryId;
  final List<String> description;
  final PhysicalParameters physicalParameters;
  final String status;
  final int stockLevel;
  final bool isSellAllowed;
  final String stuffStatus;
  final Pricing pricing;
  final List<ProductImage> images;
  final ProductImage mainImage;
  final List<ProductVideo> videos;
  final List<Variant> variants;
  final bool hasHierarchicalConfigurators;
  final String externalUrl;
  final int minOrderQuantity;
  final int quantityStep;
  final String createdTime;
  final String updatedTime;
  final ProductMeta meta;
  final List<CustomerReview> customerReviews;
  final List<RecommendedProduct> recommendedProducts;

  ProductDetails({
    required this.id,
    required this.title,
    required this.provider,
    required this.brandName,
    required this.vendorName,
    required this.categoryId,
    required this.description,
    required this.physicalParameters,
    required this.status,
    required this.stockLevel,
    required this.isSellAllowed,
    required this.stuffStatus,
    required this.pricing,
    required this.images,
    required this.mainImage,
    required this.videos,
    required this.variants,
    required this.hasHierarchicalConfigurators,
    required this.externalUrl,
    required this.minOrderQuantity,
    required this.quantityStep,
    required this.createdTime,
    required this.updatedTime,
    required this.meta,
    required this.customerReviews,
    required this.recommendedProducts,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      vendorName: json['vendorName'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      description: (json['description'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      physicalParameters: PhysicalParameters.fromJson(
        json['physicalParameters'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      status: json['status'] as String? ?? '',
      stockLevel: json['stockLevel'] as int? ?? 0,
      isSellAllowed: json['isSellAllowed'] as bool? ?? false,
      stuffStatus: json['stuffStatus'] as String? ?? '',
      pricing: Pricing.fromJson(
        json['pricing'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      images: (json['images'] as List<dynamic>?)
              ?.map((item) => ProductImage.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      mainImage: ProductImage.fromJson(
        json['mainImage'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      videos: (json['videos'] as List<dynamic>?)
              ?.map((item) => ProductVideo.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      variants: (json['variants'] as List<dynamic>?)
              ?.map((item) => Variant.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      hasHierarchicalConfigurators:
          json['hasHierarchicalConfigurators'] as bool? ?? false,
      externalUrl: json['externalUrl'] as String? ?? '',
      minOrderQuantity: json['minOrderQuantity'] as int? ?? 1,
      quantityStep: json['quantityStep'] as int? ?? 1,
      createdTime: json['createdTime'] as String? ?? '',
      updatedTime: json['updatedTime'] as String? ?? '',
      meta: ProductMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      customerReviews: (json['customerReviews'] as List<dynamic>?)
              ?.map((item) => CustomerReview.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedProducts: (json['recommendedProducts'] as List<dynamic>?)
              ?.map((item) =>
                  RecommendedProduct.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'brandName': brandName,
      'vendorName': vendorName,
      'categoryId': categoryId,
      'description': description,
      'physicalParameters': physicalParameters.toJson(),
      'status': status,
      'stockLevel': stockLevel,
      'isSellAllowed': isSellAllowed,
      'stuffStatus': stuffStatus,
      'pricing': pricing.toJson(),
      'images': images.map((img) => img.toJson()).toList(),
      'mainImage': mainImage.toJson(),
      'videos': videos.map((vid) => vid.toJson()).toList(),
      'variants': variants.map((v) => v.toJson()).toList(),
      'hasHierarchicalConfigurators': hasHierarchicalConfigurators,
      'externalUrl': externalUrl,
      'minOrderQuantity': minOrderQuantity,
      'quantityStep': quantityStep,
      'createdTime': createdTime,
      'updatedTime': updatedTime,
      'meta': meta.toJson(),
      'customerReviews': customerReviews.map((r) => r.toJson()).toList(),
      'recommendedProducts':
          recommendedProducts.map((p) => p.toJson()).toList(),
    };
  }
}
