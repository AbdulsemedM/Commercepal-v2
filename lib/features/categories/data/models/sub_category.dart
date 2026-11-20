class SubCategory {
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int displayOrder;
  final String categoryName;
  final String providerId;

  SubCategory({
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    required this.displayOrder,
    required this.categoryName,
    required this.providerId,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'categoryName': categoryName,
      'providerId': providerId,
    };
  }
}
