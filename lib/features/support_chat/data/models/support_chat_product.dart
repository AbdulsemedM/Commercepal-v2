class SupportChatProduct {
  const SupportChatProduct({
    required this.id,
    required this.title,
    this.image,
    this.price,
  });

  final String id;
  final String title;
  final String? image;
  final String? price;

  factory SupportChatProduct.fromJson(Map<String, dynamic> json) {
    final Object? images = json['images'];
    String? imageUrl;
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first?.toString();
    } else {
      imageUrl = json['image']?.toString() ?? json['imageUrl']?.toString();
    }

    String? priceText;
    final Object? pricing = json['pricing'];
    if (pricing is Map<String, dynamic>) {
      priceText = pricing['formattedCurrentPrice']?.toString();
      priceText ??= pricing['currentPrice']?.toString();
    }
    priceText ??= json['price']?.toString();

    return SupportChatProduct(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      image: imageUrl,
      price: priceText,
    );
  }
}
