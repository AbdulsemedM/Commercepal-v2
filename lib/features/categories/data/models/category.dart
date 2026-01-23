import 'sub_category.dart';

class Category {
  final String id;
  final String name;
  final String slug;
  final String code;
  final String? description;
  final String? imageUrl;
  final int displayOrder;
  final String providerId;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.code,
    this.description,
    this.imageUrl,
    required this.displayOrder,
    required this.providerId,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final subCategoriesJson = json['subCategories'] as List<dynamic>? ?? [];
    final subCategories = subCategoriesJson
        .map((item) => SubCategory.fromJson(item as Map<String, dynamic>))
        .toList();

    // Handle id field - can be string, number, or in _id format
    String categoryId = '';
    if (json['id'] != null) {
      categoryId = json['id'].toString();
    } else if (json['_id'] != null) {
      categoryId = json['_id'].toString();
    }

    return Category(
      id: categoryId,
      name: json['name'] as String,
      slug: json['slug'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      providerId: json['providerId'] as String,
      subCategories: subCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'code': code,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'providerId': providerId,
      'subCategories': subCategories.map((sub) => sub.toJson()).toList(),
    };
  }
}
