class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final String? provider;
  final String? brandId;
  final String? brandName;
  final String? categoryId;
  final String? categoryName;
  final String currency;
  final bool? isTmall;
  final int? volume;
  final String? stockStatus;
  final bool? isAvailable;
  final double? rating;
  final int? reviewCount;
  final bool isOnDiscount;
  final int? discountPercentage;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.provider,
    this.brandId,
    this.brandName,
    this.categoryId,
    this.categoryName,
    required this.currency,
    this.isTmall,
    this.volume,
    this.stockStatus,
    this.isAvailable,
    this.rating,
    this.reviewCount,
    this.isOnDiscount = false,
    this.discountPercentage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle nested pricing structure
    final pricing = json['pricing'] as Map<String, dynamic>?;
    final images = json['images'] as Map<String, dynamic>?;
    final meta = json['meta'] as Map<String, dynamic>?;
    
    return Product(
      id: json['id'] as String? ?? json['productId'] as String? ?? '',
      name: json['title'] as String? ?? 
            json['name'] as String? ?? 
            json['productName'] as String? ?? '',
      description: json['description'] as String?,
      
      // Extract price from nested pricing or flat structure
      price: pricing != null
          ? (pricing['currentPrice'] as num?)?.toDouble() ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 
            (json['unitPrice'] as num?)?.toDouble() ?? 
            (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      
      originalPrice: pricing?['originalPrice'] != null
          ? (pricing!['originalPrice'] as num).toDouble()
          : null,
      
      // Extract image from nested images or flat structure
      imageUrl: images?['thumbnail'] as String? ?? 
                images?['main'] as String? ??
                json['imageUrl'] as String? ?? 
                json['productImageUrl'] as String? ??
                json['image'] as String?,
      
      provider: json['provider'] as String?,
      brandId: json['brandId'] as String?,
      brandName: json['brandName'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      
      // Extract currency from nested pricing or flat structure
      currency: pricing?['currency'] as String? ?? 
                json['currency'] as String? ?? 'USD',
      
      isTmall: json['isTmall'] as bool?,
      volume: json['volume'] as int?,
      stockStatus: json['stockStatus'] as String? ?? json['status'] as String?,
      isAvailable: json['isAvailable'] as bool?,
      
      // Extract rating and review count from meta
      rating: meta?['rating'] != null
          ? (meta!['rating'] as num).toDouble()
          : null,
      reviewCount: meta?['reviewCount'] as int?,
      
      // Extract discount info from pricing
      isOnDiscount: pricing?['isOnDiscount'] as bool? ?? false,
      discountPercentage: pricing?['discountPercentage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (provider != null) 'provider': provider,
      if (brandId != null) 'brandId': brandId,
      if (brandName != null) 'brandName': brandName,
      if (categoryId != null) 'categoryId': categoryId,
      if (categoryName != null) 'categoryName': categoryName,
      'currency': currency,
      if (isTmall != null) 'isTmall': isTmall,
      if (volume != null) 'volume': volume,
      if (stockStatus != null) 'stockStatus': stockStatus,
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'reviewCount': reviewCount,
      'isOnDiscount': isOnDiscount,
      if (discountPercentage != null) 'discountPercentage': discountPercentage,
    };
  }
}
