/// Folder-backed subcategory catalog under
/// `assets/images/subcategories/{parent}/{slug}.jpg`.
class SubcategoryAssetEntry {
  const SubcategoryAssetEntry({
    required this.slug,
    required this.displayName,
    required this.assetPath,
    required this.parentFolder,
  });

  final String slug;
  final String displayName;
  final String assetPath;
  final String parentFolder;
}

class SubcategoryAssetCatalog {
  SubcategoryAssetCatalog._();

  static const String _root = 'assets/images/subcategories';

  /// Canonical parent folder → subcategory slugs (filenames without .jpg).
  static const Map<String, List<String>> _folderSlugs = {
    'automotive': <String>['car-accessories'],
    'baby': <String>['baby-toys', 'kids-clothes', 'kids-games'],
    'cosmetics': <String>[
      'beauty',
      'body-lotion',
      'body-mist',
      'foundation',
      'lipstick',
      'makeup',
      'mens-cologne',
      'perfume',
      'skincare',
      'womens-perfume',
    ],
    'electronics': <String>[
      'bluetooth-earbuds',
      'headphones',
      'keyboards',
      'microphones',
      'phone-cases',
      'phone-holders',
    ],
    'fashion': <String>[
      'abayas',
      'backpacks',
      'belts',
      'boots',
      'bracelets',
      'dresses',
      'earrings',
      'gift-sets',
      'handbags',
      'hats',
      'hijabs',
      'men-jackets',
      'men-jeans',
      'mens-clothing',
      'men-shirts',
      'men-shoes',
      'modest-dresses',
      'necklaces',
      'prayer-clothes',
      'sandals',
      'sneakers',
      'sunglasses',
      'tops',
      'wallets',
      'womens-clothing',
      'women-shoes',
    ],
    'home': <String>[
      'air-fryers',
      'blenders',
      'chairs',
      'furnitures',
      'kitchen-tools',
      'shelves',
      'sofas',
      'vacuum-cleaners',
    ],
    'sport': <String>['fitness-equipment'],
    'technology': <String>[
      'accessories',
      'computer-mice',
      'laptops',
      'monitors',
      'smartphones',
      'tablets',
    ],
    'watch': <String>[
      'digital-watches',
      'fashion-watches',
      'mens-watches',
      'womens-watches',
    ],
  };

  /// API / UI parent name aliases → canonical folder name.
  static const Map<String, String> _parentAliases = {
    'automotive': 'automotive',
    'auto': 'automotive',
    'vehicle': 'automotive',
    'vehicles': 'automotive',
    'baby': 'baby',
    'baby products': 'baby',
    'kids': 'baby',
    'children': 'baby',
    'cosmetics': 'cosmetics',
    'cosmetic': 'cosmetics',
    'beauty': 'cosmetics',
    'makeup': 'cosmetics',
    'electronics': 'electronics',
    'electronic': 'electronics',
    'fashion': 'fashion',
    'clothing': 'fashion',
    'clothes': 'fashion',
    'home': 'home',
    'home and life': 'home',
    'home appliances': 'home',
    'home appliance': 'home',
    'appliances': 'home',
    'furniture': 'home',
    'sport': 'sport',
    'sports': 'sport',
    'sporting': 'sport',
    'fitness': 'sport',
    'technology': 'technology',
    'tech': 'technology',
    'computers': 'technology',
    'computer': 'technology',
    'watch': 'watch',
    'watches': 'watch',
    'jewelry': 'watch',
  };

  /// Special display-name overrides for awkward filenames.
  static const Map<String, String> _displayNameOverrides = {
    'womens-clothing': "Women's Clothing",
    'mens-clothing': "Men's Clothing",
    'womens-perfume': "Women's Perfume",
    'mens-cologne': "Men's Cologne",
    'womens-watches': "Women's Watches",
    'mens-watches': "Men's Watches",
    'furnitures': 'Furniture',
    'computer-mice': 'Computer Mice',
    'bluetooth-earbuds': 'Bluetooth Earbuds',
    'phone-cases': 'Phone Cases',
    'phone-holders': 'Phone Holders',
    'car-accessories': 'Car Accessories',
    'baby-toys': 'Baby Toys',
    'kids-clothes': 'Kids Clothes',
    'kids-games': 'Kids Games',
    'body-lotion': 'Body Lotion',
    'body-mist': 'Body Mist',
    'gift-sets': 'Gift Sets',
    'men-jackets': 'Men Jackets',
    'men-jeans': 'Men Jeans',
    'men-shirts': 'Men Shirts',
    'men-shoes': 'Men Shoes',
    'modest-dresses': 'Modest Dresses',
    'prayer-clothes': 'Prayer Clothes',
    'women-shoes': 'Women Shoes',
    'air-fryers': 'Air Fryers',
    'kitchen-tools': 'Kitchen Tools',
    'vacuum-cleaners': 'Vacuum Cleaners',
    'fitness-equipment': 'Fitness Equipment',
    'digital-watches': 'Digital Watches',
    'fashion-watches': 'Fashion Watches',
  };

  static final Map<String, List<SubcategoryAssetEntry>> _entriesByFolder =
      <String, List<SubcategoryAssetEntry>>{
    for (final MapEntry<String, List<String>> e in _folderSlugs.entries)
      e.key: <SubcategoryAssetEntry>[
        for (final String slug in e.value)
          SubcategoryAssetEntry(
            slug: slug,
            displayName: displayNameFromSlug(slug),
            assetPath: '$_root/${e.key}/$slug.jpg',
            parentFolder: e.key,
          ),
      ],
  };

  static final Map<String, String> _assetByNormalizedName = <String, String>{
    for (final List<SubcategoryAssetEntry> entries in _entriesByFolder.values)
      for (final SubcategoryAssetEntry entry in entries) ...{
        _normalize(entry.displayName): entry.assetPath,
        _normalize(entry.slug.replaceAll('-', ' ')): entry.assetPath,
        entry.slug: entry.assetPath,
      },
  };

  /// Whether [parentName] has a matching asset folder.
  static bool hasFolderForParent(String parentName) {
    return _resolveFolder(parentName) != null;
  }

  /// Subcategory entries for a parent category name, or empty if no folder.
  static List<SubcategoryAssetEntry> subsForParent(String parentName) {
    final String? folder = _resolveFolder(parentName);
    if (folder == null) return const <SubcategoryAssetEntry>[];
    return List<SubcategoryAssetEntry>.from(
      _entriesByFolder[folder] ?? const <SubcategoryAssetEntry>[],
    );
  }

  /// Nested asset path for a subcategory display name or slug.
  static String? assetPathForSubcategory(String name) {
    final String normalized = _normalize(name);
    final String? direct = _assetByNormalizedName[normalized];
    if (direct != null) return direct;

    final String slug = normalized.replaceAll(' ', '-');
    return _assetByNormalizedName[slug];
  }

  static String displayNameFromSlug(String slug) {
    final String? override = _displayNameOverrides[slug];
    if (override != null) return override;

    return slug
        .split('-')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }

  static String? _resolveFolder(String parentName) {
    final String normalized = _normalize(parentName);
    final String? exact = _parentAliases[normalized];
    if (exact != null) return exact;

    for (final MapEntry<String, String> entry in _parentAliases.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }
    return null;
  }

  static String _normalize(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
