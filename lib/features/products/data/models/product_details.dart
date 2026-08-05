import 'package:commercepal/core/utils/json_utils.dart';

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
    final List<dynamic>? imagesList = JsonUtils.asList(json['images']);
    final List<dynamic>? videosList = JsonUtils.asList(json['videos']);
    final List<dynamic>? variantsList = JsonUtils.asList(json['variants']);
    final List<dynamic>? reviewsList = JsonUtils.asList(json['customerReviews']);
    final List<dynamic>? recommendedList =
        JsonUtils.asList(json['recommendedProducts']);

    return ProductDetails(
      id: JsonUtils.asString(json['id']),
      title: JsonUtils.asString(json['title']),
      provider: JsonUtils.asString(json['provider']),
      brandName: JsonUtils.asString(json['brandName']),
      vendorName: JsonUtils.asString(json['vendorName']),
      categoryId: JsonUtils.asString(json['categoryId']),
      description: JsonUtils.asStringList(json['description']),
      physicalParameters: PhysicalParameters.fromJson(
        JsonUtils.asMap(json['physicalParameters']) ??
            const <String, dynamic>{},
      ),
      status: JsonUtils.asString(json['status']),
      stockLevel: JsonUtils.asIntOr(json['stockLevel'], 0),
      isSellAllowed: JsonUtils.asBool(json['isSellAllowed']),
      stuffStatus: JsonUtils.asString(json['stuffStatus']),
      pricing: Pricing.fromJson(
        JsonUtils.asMap(json['pricing']) ?? const <String, dynamic>{},
      ),
      images: imagesList
              ?.whereType<Map>()
              .map(
                (Map item) => ProductImage.fromJson(
                  JsonUtils.asMap(item) ?? const <String, dynamic>{},
                ),
              )
              .toList() ??
          const <ProductImage>[],
      mainImage: ProductImage.fromJson(
        JsonUtils.asMap(json['mainImage']) ?? const <String, dynamic>{},
      ),
      videos: videosList
              ?.whereType<Map>()
              .map(
                (Map item) => ProductVideo.fromJson(
                  JsonUtils.asMap(item) ?? const <String, dynamic>{},
                ),
              )
              .toList() ??
          const <ProductVideo>[],
      variants: variantsList
              ?.whereType<Map>()
              .map(
                (Map item) => Variant.fromJson(
                  JsonUtils.asMap(item) ?? const <String, dynamic>{},
                ),
              )
              .toList() ??
          const <Variant>[],
      hasHierarchicalConfigurators:
          JsonUtils.asBool(json['hasHierarchicalConfigurators']),
      externalUrl: JsonUtils.asString(json['externalUrl']),
      minOrderQuantity: JsonUtils.asIntOr(json['minOrderQuantity'], 1),
      quantityStep: JsonUtils.asIntOr(json['quantityStep'], 1),
      createdTime: JsonUtils.asString(json['createdTime']),
      updatedTime: JsonUtils.asString(json['updatedTime']),
      meta: ProductMeta.fromJson(
        JsonUtils.asMap(json['meta']) ?? const <String, dynamic>{},
      ),
      customerReviews: reviewsList
              ?.whereType<Map>()
              .map(
                (Map item) => CustomerReview.fromJson(
                  JsonUtils.asMap(item) ?? const <String, dynamic>{},
                ),
              )
              .toList() ??
          const <CustomerReview>[],
      // Skip invalid recommended items so one bad entry cannot fail the PDP.
      recommendedProducts: recommendedList
              ?.whereType<Map>()
              .map(
                (Map item) => RecommendedProduct.tryFromJson(
                  JsonUtils.asMap(item) ?? const <String, dynamic>{},
                ),
              )
              .whereType<RecommendedProduct>()
              .toList() ??
          const <RecommendedProduct>[],
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
