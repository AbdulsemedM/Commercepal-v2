/// A product saved in the local wishlist (id, name, image URL).
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
    };
  }
}
