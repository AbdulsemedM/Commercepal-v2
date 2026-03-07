import 'package:commercepal/features/products/data/models/product.dart';

/// A product saved in the local wishlist (id, name, image URL).
/// Can also be created from API [Product] for display.
class WishlistItem {
  const WishlistItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
  });

  final String productId;
  final String productName;
  final String imageUrl;

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  /// Create from API product for unified display in wishlist screen.
  factory WishlistItem.fromProduct(Product product) {
    return WishlistItem(
      productId: product.id,
      productName: product.name,
      imageUrl: product.imageUrl ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
    };
  }
}
