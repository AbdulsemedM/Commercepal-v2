import 'category.dart';
import 'sub_category.dart';
import 'subcategory_asset_catalog.dart';

/// Minimum number of subcategories every parent category should expose in the UI
/// when it has no matching asset folder.
const int kMinSubCategoriesPerCategory = 4;

/// Enriches API categories with folder-backed subcategory lists (and images via
/// [SubcategoryAssetCatalog]), or min-4 searchable fillers for other parents.
///
/// Tapping a subcategory opens product search with the subcategory [name].
class CategorySubcategoryFallbacks {
  CategorySubcategoryFallbacks._();

  static const List<String> _genericFallbacks = <String>[
    'Best Sellers',
    'New Arrivals',
    'Top Deals',
    'Popular Picks',
    'Trending Now',
    'Featured Items',
  ];

  /// Unique HTTPS image for filler / non-folder subcategories.
  static String imageUrlFor(String subcategoryName) {
    final String seed = slugify(subcategoryName);
    return 'https://picsum.photos/seed/cp-$seed/400/400';
  }

  /// Ensures [category] has displayable subcategories.
  ///
  /// Parents with a matching asset folder use that folder as the source of
  /// truth (API entries that match a folder name are preserved; `imageUrl` is
  /// cleared so nested local assets win). Other parents keep min-4 fillers
  /// with unique remote image URLs.
  static Category enrich(Category category) {
    if (SubcategoryAssetCatalog.hasFolderForParent(category.name)) {
      return _enrichFromFolder(category);
    }
    return _enrichWithFillers(category);
  }

  static List<Category> enrichAll(List<Category> categories) {
    return categories.map(enrich).toList(growable: false);
  }

  /// Folder-backed subcategory display names for a parent, or generic fillers.
  static List<String> fallbackNamesFor(String categoryName) {
    final List<SubcategoryAssetEntry> folder =
        SubcategoryAssetCatalog.subsForParent(categoryName);
    if (folder.isNotEmpty) {
      return folder.map((e) => e.displayName).toList(growable: false);
    }
    return List<String>.from(_genericFallbacks);
  }

  static String slugify(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r"[^a-z0-9\s-]"), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static Category _enrichFromFolder(Category category) {
    final List<SubcategoryAssetEntry> folderSubs =
        SubcategoryAssetCatalog.subsForParent(category.name);

    final Map<String, SubCategory> apiByName = <String, SubCategory>{
      for (final SubCategory sub in category.subCategories)
        _normalizeKey(sub.name): sub,
    };

    final List<SubCategory> result = <SubCategory>[];
    var order = 1;
    for (final SubcategoryAssetEntry entry in folderSubs) {
      final SubCategory? existing = apiByName[_normalizeKey(entry.displayName)] ??
          apiByName[_normalizeKey(entry.slug.replaceAll('-', ' '))];

      result.add(
        SubCategory(
          name: entry.displayName,
          slug: existing?.slug.isNotEmpty == true ? existing!.slug : entry.slug,
          description: existing?.description,
          // Prefer nested local assets in the UI.
          imageUrl: null,
          displayOrder: order++,
          categoryName: category.name,
          providerId: category.providerId,
        ),
      );
    }

    return _copyCategory(category, result);
  }

  static Category _enrichWithFillers(Category category) {
    var existing = List<SubCategory>.from(category.subCategories);
    final seen = <String>{
      for (final SubCategory sub in existing) _normalizeKey(sub.name),
    };

    if (existing.length < kMinSubCategoriesPerCategory) {
      final List<String> fallbackNames = fallbackNamesFor(category.name);
      var nextOrder = existing.isEmpty
          ? 1
          : existing
                  .map((s) => s.displayOrder)
                  .fold<int>(0, (a, b) => a > b ? a : b) +
              1;

      for (final String name in fallbackNames) {
        if (existing.length >= kMinSubCategoriesPerCategory) break;
        final String key = _normalizeKey(name);
        if (key.isEmpty || !seen.add(key)) continue;

        existing.add(
          SubCategory(
            name: name,
            slug: slugify(name),
            description: null,
            imageUrl: imageUrlFor(name),
            displayOrder: nextOrder++,
            categoryName: category.name,
            providerId: category.providerId,
          ),
        );
      }

      var genericIndex = 0;
      while (existing.length < kMinSubCategoriesPerCategory &&
          genericIndex < _genericFallbacks.length) {
        final String name = _genericFallbacks[genericIndex++];
        final String key = _normalizeKey(name);
        if (!seen.add(key)) continue;
        existing.add(
          SubCategory(
            name: name,
            slug: slugify(name),
            description: null,
            imageUrl: imageUrlFor(name),
            displayOrder: nextOrder++,
            categoryName: category.name,
            providerId: category.providerId,
          ),
        );
      }
    }

    existing = existing
        .map((SubCategory sub) {
          if (sub.imageUrl != null && sub.imageUrl!.isNotEmpty) return sub;
          return SubCategory(
            name: sub.name,
            slug: sub.slug,
            description: sub.description,
            imageUrl: imageUrlFor(sub.name),
            displayOrder: sub.displayOrder,
            categoryName: sub.categoryName,
            providerId: sub.providerId,
          );
        })
        .toList();

    return _copyCategory(category, existing);
  }

  static Category _copyCategory(Category category, List<SubCategory> subs) {
    return Category(
      id: category.id,
      name: category.name,
      slug: category.slug,
      code: category.code,
      description: category.description,
      imageUrl: category.imageUrl,
      displayOrder: category.displayOrder,
      providerId: category.providerId,
      subCategories: subs,
    );
  }

  static String _normalizeKey(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
