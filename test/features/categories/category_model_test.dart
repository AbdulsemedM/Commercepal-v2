import 'package:commercepal/features/categories/data/models/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category with missing fields parses instead of throwing', () {
    final Category category = Category.fromJson(<String, dynamic>{
      'name': 'Consumer Electronics',
      'slug': 'consumer-electronics',
      'providerId': null,
      'displayOrder': 9,
      'subCategories': <dynamic>[
        <String, dynamic>{
          'name': 'Home Audio & Video',
          'providerId': 'SECOND-ID',
          'description': null,
        },
        <String, dynamic>{'name': null},
        'not a map',
      ],
    });

    expect(category.name, 'Consumer Electronics');
    expect(category.providerId, '');
    expect(category.code, '');
    expect(category.subCategories, hasLength(1));
    expect(category.subCategories.single.providerId, 'SECOND-ID');
    expect(category.subCategories.single.categoryName, '');
  });
}
