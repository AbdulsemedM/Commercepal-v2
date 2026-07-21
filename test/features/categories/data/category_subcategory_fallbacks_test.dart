import 'package:commercepal/features/categories/data/models/category.dart';
import 'package:commercepal/features/categories/data/models/category_subcategory_fallbacks.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
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
}) {
  return SubCategory(
    name: name,
    slug: CategorySubcategoryFallbacks.slugify(name),
    displayOrder: displayOrder,
    categoryName: categoryName,
    providerId: providerId,
  );
}

void main() {
  group('CategorySubcategoryFallbacks.enrich', () {
    test('fills empty category to at least four subcategories', () {
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Electronics'),
      );

      expect(
        enriched.subCategories.length,
        greaterThanOrEqualTo(kMinSubCategoriesPerCategory),
      );
      expect(
        enriched.subCategories.map((s) => s.name).toSet().length,
        enriched.subCategories.length,
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

    test('preserves existing API subcategories first', () {
      final existing = <SubCategory>[
        _sub(name: 'Custom Widgets', categoryName: 'Fashion', displayOrder: 1),
        _sub(name: 'Custom Gadgets', categoryName: 'Fashion', displayOrder: 2),
      ];
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Fashion', subCategories: existing),
      );

      expect(enriched.subCategories.length, greaterThanOrEqualTo(4));
      expect(enriched.subCategories[0].name, 'Custom Widgets');
      expect(enriched.subCategories[1].name, 'Custom Gadgets');
    });

    test('does not alter already-complete categories', () {
      final existing = <SubCategory>[
        _sub(name: 'A', categoryName: 'Sport', displayOrder: 1),
        _sub(name: 'B', categoryName: 'Sport', displayOrder: 2),
        _sub(name: 'C', categoryName: 'Sport', displayOrder: 3),
        _sub(name: 'D', categoryName: 'Sport', displayOrder: 4),
        _sub(name: 'E', categoryName: 'Sport', displayOrder: 5),
      ];
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Sport', subCategories: existing),
      );

      expect(enriched.subCategories.length, 5);
      expect(
        enriched.subCategories.map((s) => s.name).toList(),
        <String>['A', 'B', 'C', 'D', 'E'],
      );
    });

    test('deduplicates case-insensitively when appending fillers', () {
      final existing = <SubCategory>[
        _sub(name: 'smartphones', categoryName: 'Technology', displayOrder: 1),
        _sub(name: 'Laptops', categoryName: 'Technology', displayOrder: 2),
      ];
      final enriched = CategorySubcategoryFallbacks.enrich(
        _category(name: 'Technology', subCategories: existing),
      );

      expect(enriched.subCategories.length, greaterThanOrEqualTo(4));
      final keys = enriched.subCategories
          .map((s) => s.name.toLowerCase().trim())
          .toSet();
      expect(keys.length, enriched.subCategories.length);
      expect(keys.contains('smartphones'), isTrue);
      expect(keys.contains('laptops'), isTrue);
    });

    test('uses curated names for known parents', () {
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
    });

    test('enrichAll applies to every category', () {
      final result = CategorySubcategoryFallbacks.enrichAll(<Category>[
        _category(name: 'Fashion'),
        _category(name: 'Automotive'),
        _category(name: 'Mystery Category'),
      ]);

      expect(result.length, 3);
      for (final category in result) {
        expect(
          category.subCategories.length,
          greaterThanOrEqualTo(kMinSubCategoriesPerCategory),
        );
      }
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
  });
}
