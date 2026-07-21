import 'category.dart';
import 'sub_category.dart';

/// Minimum number of subcategories every parent category should expose in the UI.
const int kMinSubCategoriesPerCategory = 4;

/// Client-side catalog of thoughtful, searchable subcategory names keyed by
/// normalized parent-category aliases.
///
/// Tapping a subcategory opens product search with the subcategory [name], so
/// phrases should be concrete product search terms rather than vague labels.
class CategorySubcategoryFallbacks {
  CategorySubcategoryFallbacks._();

  /// Known parent groups → curated searchable subcategory names.
  static const Map<String, List<String>> _catalog = {
    // Electronics / Technology
    'electronics': [
      'Smartphones',
      'Laptops',
      'Headphones',
      'Smart Watches',
      'Tablets',
      'Chargers',
    ],
    'technology': [
      'Smartphones',
      'Laptops',
      'Headphones',
      'Smart Watches',
      'Tablets',
      'Chargers',
    ],
    'tech': [
      'Smartphones',
      'Laptops',
      'Headphones',
      'Smart Watches',
    ],

    // Phones / Tablets
    'phones': [
      'Smartphones',
      'Phone Cases',
      'Chargers',
      'Screen Protectors',
      'Power Banks',
    ],
    'mobile': [
      'Smartphones',
      'Phone Cases',
      'Chargers',
      'Screen Protectors',
    ],
    'smartphone': [
      'Android Phones',
      'Phone Cases',
      'Chargers',
      'Power Banks',
    ],
    'tablets': [
      'Android Tablets',
      'Tablet Cases',
      'Stylus Pens',
      'Tablet Keyboards',
    ],
    'tablet': [
      'Android Tablets',
      'Tablet Cases',
      'Stylus Pens',
      'Tablet Keyboards',
    ],

    // Computers
    'computers': [
      'Laptops',
      'Desktop PCs',
      'Monitors',
      'Keyboards',
      'Computer Mice',
    ],
    'computer': [
      'Laptops',
      'Desktop PCs',
      'Monitors',
      'Keyboards',
    ],
    'laptop': [
      'Gaming Laptops',
      'Laptop Bags',
      'Laptop Stands',
      'Laptop Chargers',
    ],
    'laptops': [
      'Gaming Laptops',
      'Laptop Bags',
      'Laptop Stands',
      'Laptop Chargers',
    ],
    'desktop': [
      'Desktop PCs',
      'Monitors',
      'Keyboards',
      'Webcams',
    ],

    // Fashion
    'fashion': [
      "Women's Clothing",
      "Men's Clothing",
      'Shoes',
      'Bags',
      'Accessories',
    ],
    'clothing': [
      "Women's Clothing",
      "Men's Clothing",
      'Shoes',
      'Bags',
    ],
    'clothes': [
      "Women's Clothing",
      "Men's Clothing",
      'Shoes',
      'Bags',
    ],
    "women's fashion": [
      'Dresses',
      'Tops',
      'Handbags',
      'Women Shoes',
    ],
    'womens fashion': [
      'Dresses',
      'Tops',
      'Handbags',
      'Women Shoes',
    ],
    "men's fashion": [
      'Men Shirts',
      'Men Jeans',
      'Men Shoes',
      'Men Jackets',
    ],
    'mens fashion': [
      'Men Shirts',
      'Men Jeans',
      'Men Shoes',
      'Men Jackets',
    ],
    'shoes': [
      'Sneakers',
      'Sandals',
      'Boots',
      'Formal Shoes',
    ],
    'abaya': [
      'Abayas',
      'Hijabs',
      'Modest Dresses',
      'Prayer Clothes',
    ],
    'abayas': [
      'Abayas',
      'Hijabs',
      'Modest Dresses',
      'Prayer Clothes',
    ],

    // Beauty / Cosmetics
    'cosmetics': [
      'Makeup',
      'Skincare',
      'Perfume',
      'Hair Care',
      'Lotion',
    ],
    'beauty': [
      'Makeup',
      'Skincare',
      'Perfume',
      'Hair Care',
    ],
    'makeup': [
      'Foundation',
      'Lipstick',
      'Mascara',
      'Eyeshadow',
    ],
    'perfume': [
      "Women's Perfume",
      "Men's Cologne",
      'Body Mist',
      'Gift Sets',
    ],
    'skincare': [
      'Moisturizer',
      'Face Wash',
      'Serum',
      'Sunscreen',
    ],
    'lotion': [
      'Body Lotion',
      'Hand Cream',
      'Face Cream',
      'Sunscreen',
    ],

    // Home / Appliances
    'home appliances': [
      'Blenders',
      'Irons',
      'Vacuum Cleaners',
      'Air Fryers',
      'Rice Cookers',
    ],
    'home appliance': [
      'Blenders',
      'Irons',
      'Vacuum Cleaners',
      'Air Fryers',
    ],
    'appliances': [
      'Blenders',
      'Irons',
      'Vacuum Cleaners',
      'Air Fryers',
    ],
    'home': [
      'Kitchen Tools',
      'Bedding',
      'Lighting',
      'Storage',
    ],
    'home and life': [
      'Kitchen Tools',
      'Bedding',
      'Lighting',
      'Storage',
    ],
    'furniture': [
      'Sofas',
      'Tables',
      'Chairs',
      'Shelves',
    ],

    // Automotive
    'automotive': [
      'Car Accessories',
      'Car Chargers',
      'Dash Cams',
      'Car Covers',
      'Phone Holders',
    ],
    'auto': [
      'Car Accessories',
      'Car Chargers',
      'Dash Cams',
      'Car Covers',
    ],
    'vehicles': [
      'Car Accessories',
      'Car Chargers',
      'Dash Cams',
      'Car Covers',
    ],
    'vehicle': [
      'Car Accessories',
      'Car Chargers',
      'Dash Cams',
      'Car Covers',
    ],

    // Sports
    'sport': [
      'Sports Shoes',
      'Fitness Equipment',
      'Yoga Mats',
      'Water Bottles',
      'Sportswear',
    ],
    'sports': [
      'Sports Shoes',
      'Fitness Equipment',
      'Yoga Mats',
      'Water Bottles',
    ],
    'sporting': [
      'Sports Shoes',
      'Fitness Equipment',
      'Yoga Mats',
      'Water Bottles',
    ],
    'fitness': [
      'Dumbbells',
      'Yoga Mats',
      'Resistance Bands',
      'Sportswear',
    ],

    // Watches / Jewelry
    'watch': [
      'Smart Watches',
      "Men's Watches",
      "Women's Watches",
      'Watch Straps',
    ],
    'watches': [
      'Smart Watches',
      "Men's Watches",
      "Women's Watches",
      'Watch Straps',
    ],
    'smart watch': [
      'Fitness Trackers',
      'Smart Watch Bands',
      'Chargers',
      'Protective Cases',
    ],
    'smartwatch': [
      'Fitness Trackers',
      'Smart Watch Bands',
      'Chargers',
      'Protective Cases',
    ],
    "men's watch": [
      'Analog Watches',
      'Digital Watches',
      'Watch Straps',
      'Luxury Watches',
    ],
    "men's watches": [
      'Analog Watches',
      'Digital Watches',
      'Watch Straps',
      'Luxury Watches',
    ],
    "women's watches": [
      'Analog Watches',
      'Fashion Watches',
      'Watch Straps',
      'Jewelry Watches',
    ],
    "women's watch": [
      'Analog Watches',
      'Fashion Watches',
      'Watch Straps',
      'Jewelry Watches',
    ],
    'jewelry': [
      'Necklaces',
      'Earrings',
      'Bracelets',
      'Rings',
    ],

    // Accessories
    'accessories': [
      'Bags',
      'Belts',
      'Sunglasses',
      'Hats',
      'Wallets',
    ],

    // Children / Baby
    'baby': [
      'Baby Clothes',
      'Diapers',
      'Baby Toys',
      'Feeding Bottles',
    ],
    'baby products': [
      'Baby Clothes',
      'Diapers',
      'Baby Toys',
      'Feeding Bottles',
    ],
    'kids': [
      'Kids Clothes',
      'Toys',
      'School Bags',
      'Kids Shoes',
    ],
    'toys': [
      'Educational Toys',
      'Action Figures',
      'Board Games',
      'Soft Toys',
    ],

    // Grocery / Food
    'grocery': [
      'Snacks',
      'Beverages',
      'Cooking Oil',
      'Spices',
    ],
    'food': [
      'Snacks',
      'Beverages',
      'Cooking Oil',
      'Spices',
    ],

    // Health
    'health': [
      'Vitamins',
      'First Aid',
      'Thermometers',
      'Face Masks',
    ],
    'medical': [
      'First Aid',
      'Thermometers',
      'Face Masks',
      'Hand Sanitizer',
    ],

    // Books / Education
    'books': [
      'Novels',
      'Children Books',
      'Educational Books',
      'Notebooks',
    ],
    'education': [
      'Notebooks',
      'Stationery',
      'Educational Books',
      'Backpacks',
    ],

    // Pets
    'pets': [
      'Pet Food',
      'Pet Toys',
      'Pet Beds',
      'Pet Collars',
    ],
    'pet': [
      'Pet Food',
      'Pet Toys',
      'Pet Beds',
      'Pet Collars',
    ],

    // Garden
    'garden': [
      'Garden Tools',
      'Plant Pots',
      'Seeds',
      'Watering Cans',
    ],

    // Audio
    'audio': [
      'Headphones',
      'Bluetooth Earbuds',
      'Speakers',
      'Microphones',
    ],

    // Real estate (locale key; keep useful shoppable terms)
    'real estate': [
      'Home Decor',
      'Lighting',
      'Storage',
      'Furniture',
    ],
  };

  /// Generic searchable fillers when the parent category is unknown.
  static const List<String> _genericFallbacks = [
    'Best Sellers',
    'New Arrivals',
    'Top Deals',
    'Popular Picks',
  ];

  /// Ensures [category] has at least [kMinSubCategoriesPerCategory] unique
  /// subcategories. Preserves existing API entries (order and content) and
  /// appends curated fillers only as needed.
  static Category enrich(Category category) {
    final existing = List<SubCategory>.from(category.subCategories);
    final seen = <String>{
      for (final sub in existing) _normalizeKey(sub.name),
    };

    if (existing.length >= kMinSubCategoriesPerCategory) {
      return category;
    }

    final fallbackNames = fallbackNamesFor(category.name);
    var nextOrder = existing.isEmpty
        ? 1
        : existing
                .map((s) => s.displayOrder)
                .fold<int>(0, (a, b) => a > b ? a : b) +
            1;

    for (final name in fallbackNames) {
      if (existing.length >= kMinSubCategoriesPerCategory) break;
      final key = _normalizeKey(name);
      if (key.isEmpty || !seen.add(key)) continue;

      existing.add(
        SubCategory(
          name: name,
          slug: slugify(name),
          description: null,
          imageUrl: null,
          displayOrder: nextOrder++,
          categoryName: category.name,
          providerId: category.providerId,
        ),
      );
    }

    // Absolute safety net if curated list was too short after dedupe.
    var genericIndex = 0;
    while (existing.length < kMinSubCategoriesPerCategory &&
        genericIndex < _genericFallbacks.length) {
      final name = _genericFallbacks[genericIndex++];
      final key = _normalizeKey(name);
      if (!seen.add(key)) continue;
      existing.add(
        SubCategory(
          name: name,
          slug: slugify(name),
          description: null,
          imageUrl: null,
          displayOrder: nextOrder++,
          categoryName: category.name,
          providerId: category.providerId,
        ),
      );
    }

    return Category(
      id: category.id,
      name: category.name,
      slug: category.slug,
      code: category.code,
      description: category.description,
      imageUrl: category.imageUrl,
      displayOrder: category.displayOrder,
      providerId: category.providerId,
      subCategories: existing,
    );
  }

  /// Enriches every category in [categories].
  static List<Category> enrichAll(List<Category> categories) {
    return categories.map(enrich).toList(growable: false);
  }

  /// Resolves curated subcategory names for a parent [categoryName].
  static List<String> fallbackNamesFor(String categoryName) {
    final normalized = _normalizeKey(categoryName);
    if (normalized.isEmpty) return List<String>.from(_genericFallbacks);

    final exact = _catalog[normalized];
    if (exact != null) return List<String>.from(exact);

    // Alias / contains matching for backend naming variations.
    for (final entry in _catalog.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return List<String>.from(entry.value);
      }
    }

    // Keyword heuristics for compound names.
    if (_containsAny(normalized, const ['electronic', 'technolog', 'gadget'])) {
      return List<String>.from(_catalog['electronics']!);
    }
    if (_containsAny(normalized, const ['phone', 'mobile'])) {
      return List<String>.from(_catalog['phones']!);
    }
    if (_containsAny(normalized, const ['laptop', 'computer', 'pc'])) {
      return List<String>.from(_catalog['computers']!);
    }
    if (_containsAny(normalized, const ['fashion', 'cloth', 'apparel'])) {
      return List<String>.from(_catalog['fashion']!);
    }
    if (_containsAny(normalized, const ['cosmetic', 'beauty', 'makeup'])) {
      return List<String>.from(_catalog['cosmetics']!);
    }
    if (_containsAny(normalized, const ['appliance'])) {
      return List<String>.from(_catalog['home appliances']!);
    }
    if (_containsAny(normalized, const ['auto', 'vehicle', 'car'])) {
      return List<String>.from(_catalog['automotive']!);
    }
    if (_containsAny(normalized, const ['sport', 'fitness'])) {
      return List<String>.from(_catalog['sports']!);
    }
    if (_containsAny(normalized, const ['watch', 'jewelry', 'jewellery'])) {
      return List<String>.from(_catalog['watches']!);
    }
    if (_containsAny(normalized, const ['accessor'])) {
      return List<String>.from(_catalog['accessories']!);
    }
    if (_containsAny(normalized, const ['baby', 'kid', 'child', 'toy'])) {
      return List<String>.from(_catalog['baby']!);
    }
    if (_containsAny(normalized, const ['garden', 'outdoor'])) {
      return List<String>.from(_catalog['garden']!);
    }
    if (_containsAny(normalized, const ['pet'])) {
      return List<String>.from(_catalog['pets']!);
    }
    if (_containsAny(normalized, const ['food', 'grocery'])) {
      return List<String>.from(_catalog['grocery']!);
    }
    if (_containsAny(normalized, const ['health', 'medical'])) {
      return List<String>.from(_catalog['health']!);
    }
    if (_containsAny(normalized, const ['book', 'education', 'stationery'])) {
      return List<String>.from(_catalog['books']!);
    }
    if (_containsAny(normalized, const ['audio', 'headphone', 'speaker'])) {
      return List<String>.from(_catalog['audio']!);
    }
    if (_containsAny(normalized, const ['home', 'furniture', 'kitchen'])) {
      return List<String>.from(_catalog['home']!);
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

  static String _normalizeKey(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final needle in needles) {
      if (haystack.contains(needle)) return true;
    }
    return false;
  }
}
