import 'package:commercepal/core/utils/category_image_assets.dart';
import 'package:commercepal/features/categories/data/models/category.dart';
import 'package:commercepal/features/categories/data/models/category_subcategory_fallbacks.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/features/categories/data/models/subcategory_asset_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

Category _category({
  required String name,
  List<SubCategory> subCategories = const <SubCategory>[],
  String providerId = 'provider-1',
}) {
  return Category(
    id: 'id-$name',
    name: name,
    slug: name.toLowerCase().replaceAll(' ', '-'),
    code: name.toUpperCase(),
    displayOrder: 1,
    providerId: providerId,
    subCategories: subCategories,
  );
}

SubCategory _sub({
  required String name,
  required String categoryName,
  String providerId = 'provider-1',
  int displayOrder = 1,
  String? imageUrl,
}) {
  return SubCategory(
    name: name,
    slug: CategorySubcategoryFallbacks.slugify(name),
    imageUrl: imageUrl,
    displayOrder: displayOrder,
    categoryName: categoryName,
    providerId: providerId,
  );
}

void main() {
  group('SubcategoryAssetCatalog', () {
    test('technology folder returns expected sub count and nested paths', () {
      final subs = SubcategoryAssetCatalog.subsForParent('Technology');
      expect(subs.length, 6);
      expect(
        subs.map((e) => e.displayName).toList(),
        containsAll(<String>[
          'Smartphones',
          'Laptops',
          'Tablets',
          'Monitors',
          'Computer Mice',
          'Accessories',
        ]),
      );
      expect(
        subs.every(
          (e) => e.assetPath.startsWith(
            'assets/images/subcategories/technology/',
          ),
        ),
        isTrue,
      );
      expect(
        SubcategoryAssetCatalog.assetPathForSubcategory('Smartphones'),
        'assets/images/subcategories/technology/smartphones.jpg',
      );
    });

    test('home appliances alias resolves to home folder', () {
      expect(SubcategoryAssetCatalog.hasFolderForParent('Home Appliances'), isTrue);
      final subs = SubcategoryAssetCatalog.subsForParent('Home Appliances');
      expect(subs, isNotEmpty);
      expect(subs.first.parentFolder, 'home');
      expect(
        subs.map((e) => e.displayName),
        contains('Furniture'),
      );
    });

    test('unknown parent has no folder and empty subs', () {
      expect(
        SubcategoryAssetCatalog.hasFolderForParent('Quantum Widgets X'),
        isFalse,
      );
      expect(
        SubcategoryAssetCatalog.subsForParent('Quantum Widgets X'),
        isEmpty,
      );
      expect(
        SubcategoryAssetCatalog.assetPathForSubcategory('Totally Unknown XYZ'),
        isNull,
      );
    });

    test('displayNameFromSlug applies overrides', () {
      expect(
        SubcategoryAssetCatalog.displayNameFromSlug('womens-clothing'),
        "Women's Clothing",
      );
      expect(
        SubcategoryAssetCatalog.displayNameFromSlug('furnitures'),
        'Furniture',
      );
      expect(
        SubcategoryAssetCatalog.displayNameFromSlug('kids-games'),
        'Kids Games',
      );
    });
  });

  group('CategoryImageAssets nested resolution', () {
    test('resolves nested subcategory paths', () {
      expect(
        CategoryImageAssets.assetPathForName('Headphones'),
        'assets/images/subcategories/electronics/headphones.jpg',
      );
      expect(
        CategoryImageAssets.assetPathForName("Women's Clothing"),
        'assets/images/subcategories/fashion/womens-clothing.jpg',
      );
    });

    test('still resolves parent-level assets', () {
      expect(
        CategoryImageAssets.assetPathForName('Technology'),
        'assets/images/technology.jpg',
      );
    });
  });

  group('CategorySubcategoryFallbacks.enrich', () {
    test('folder parent uses catalog list with null imageUrl', () {
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Electronics'),
      );

      expect(enriched.subCategories.length, 6);
      expect(
        enriched.subCategories.map((s) => s.name).toList(),
        containsAll(<String>[
          'Headphones',
          'Bluetooth Earbuds',
          'Keyboards',
          'Microphones',
          'Phone Cases',
          'Phone Holders',
        ]),
      );
      expect(
        enriched.subCategories.every((s) => s.imageUrl == null),
        isTrue,
      );
      expect(
        enriched.subCategories.every((s) => s.categoryName == 'Electronics'),
        isTrue,
      );
      expect(
        enriched.subCategories.every((s) => s.providerId == 'provider-1'),
        isTrue,
      );
    });

    test('preserves matching API subcategory metadata by name', () {
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(
          name: 'Fashion',
          subCategories: <SubCategory>[
            _sub(
              name: "Women's Clothing",
              categoryName: 'Fashion',
              imageUrl: 'https://cdn.example.com/api-image.jpg',
            ),
            _sub(name: 'Custom Widgets', categoryName: 'Fashion'),
          ],
        ),
      );

      expect(
        enriched.subCategories.map((s) => s.name),
        contains("Women's Clothing"),
      );
      expect(
        enriched.subCategories.map((s) => s.name),
        isNot(contains('Custom Widgets')),
      );
      final women = enriched.subCategories
          .firstWhere((s) => s.name == "Women's Clothing");
      // Folder-backed: local asset preferred over API image.
      expect(women.imageUrl, isNull);
    });

    test('cosmetics folder includes makeup and skincare', () {
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Cosmetics'),
      );
      final names = enriched.subCategories.map((s) => s.name).toList();

      expect(names, contains('Makeup'));
      expect(names, contains('Skincare'));
      expect(names.length, greaterThanOrEqualTo(4));
    });

    test('fills unknown parents with generic searchable fallbacks', () {
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Quantum Widgets X'),
      );

      expect(enriched.subCategories.length, greaterThanOrEqualTo(4));
      expect(
        enriched.subCategories.map((s) => s.name).toList(),
        containsAll(<String>[
          'Best Sellers',
          'New Arrivals',
          'Top Deals',
          'Popular Picks',
        ]),
      );
      for (final sub in enriched.subCategories) {
        expect(sub.imageUrl, isNotNull);
        expect(sub.imageUrl, startsWith('https://'));
      }
    });

    test('enrichAll applies to every category', () {
      final result = CategorySubcategoryFallbacks.enrichAll(<Category>[
        _category(name: 'Fashion'),
        _category(name: 'Automotive'),
        _category(name: 'Mystery Category'),
      ]);

      expect(result.length, 3);
      expect(result[0].subCategories.length, greaterThan(4));
      expect(result[1].subCategories.length, 1); // car-accessories only
      expect(
        result[2].subCategories.length,
        greaterThanOrEqualTo(kMinSubCategoriesPerCategory),
      );
    });

    test('slugify produces stable URL-friendly slugs', () {
      expect(
        CategorySubcategoryFallbacks.slugify("Women's Clothing"),
        'womens-clothing',
      );
      expect(
        CategorySubcategoryFallbacks.slugify('Smart Watches'),
        'smart-watches',
      );
    });

    test('preserves API-provided imageUrl on non-folder parents', () {
      final existing = <SubCategory>[
        SubCategory(
          name: 'Custom Widgets',
          slug: 'custom-widgets',
          imageUrl: 'https://cdn.example.com/api-image.jpg',
          displayOrder: 1,
          categoryName: 'Mystery Category',
          providerId: 'provider-1',
        ),
        _sub(name: 'Custom Gadgets', categoryName: 'Mystery Category'),
      ];
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Mystery Category', subCategories: existing),
      );

      expect(
        enriched.subCategories.first.imageUrl,
        'https://cdn.example.com/api-image.jpg',
      );
      final fillers = enriched.subCategories.skip(2);
      expect(
        fillers.every((s) => (s.imageUrl ?? '').startsWith('https://')),
        isTrue,
      );
    });

    test('imageUrlFor returns picsum seed URLs', () {
      expect(
        CategorySubcategoryFallbacks.imageUrlFor('Smartphones'),
        startsWith('https://picsum.photos/seed/'),
      );
      expect(
        CategorySubcategoryFallbacks.imageUrlFor('Totally Unknown XYZ'),
        startsWith('https://picsum.photos/seed/'),
      );
    });

    test('folder-backed image resolution uses nested assets', () {
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Technology'),
      );
      for (final sub in enriched.subCategories) {
        final path = CategoryImageAssets.assetPathForName(sub.name);
        expect(path, isNotNull);
        expect(path, contains('/subcategories/technology/'));
      }
    });
  });
}
