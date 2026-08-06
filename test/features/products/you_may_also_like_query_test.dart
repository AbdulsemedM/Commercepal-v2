import 'package:flutter_test/flutter_test.dart';
import 'package:commercepal/features/products/presentation/widgets/recommended_products_section.dart';

void main() {
  group('youMayAlsoLikeQuery', () {
    test('returns first two words', () {
      expect(
        youMayAlsoLikeQuery('Wireless Bluetooth Headphones Pro'),
        'Wireless Bluetooth',
      );
    });

    test('returns single word when only one', () {
      expect(youMayAlsoLikeQuery('Laptop'), 'Laptop');
    });

    test('trims and collapses whitespace', () {
      expect(youMayAlsoLikeQuery('  Red   Dress  XL  '), 'Red Dress');
    });

    test('empty title yields empty query', () {
      expect(youMayAlsoLikeQuery('   '), '');
    });
  });
}
