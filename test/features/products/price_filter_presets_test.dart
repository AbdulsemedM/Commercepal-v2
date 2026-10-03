import 'package:commercepal/features/products/presentation/widgets/price_filter_chips.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nicePriceStep rounds to half magnitudes', () {
    expect(nicePriceStep(1234), 1000);
    expect(nicePriceStep(1300), 1500);
    expect(nicePriceStep(87), 85);
    expect(nicePriceStep(23), 25);
    expect(nicePriceStep(0), 0);
  });

  test('presets follow the result price spread, not fixed dollars', () {
    final List<PriceRange> etb = pricePresetsFor(
      <double>[450, 900, 1200, 1800, 2500, 4200, 6000, 9900],
    );
    expect(etb.first.max, greaterThan(500));
    expect(etb.first.min, isNull);
    expect(etb.last.max, isNull);
    // Contiguous buckets.
    for (int i = 0; i < etb.length - 1; i++) {
      expect(etb[i].max, etb[i + 1].min);
    }
  });

  test('too few prices yields no presets', () {
    expect(pricePresetsFor(<double>[10, 20]), isEmpty);
  });

  test('PriceRange equality and contains', () {
    expect(const PriceRange(min: 1, max: 2), const PriceRange(min: 1, max: 2));
    expect(const PriceRange(max: 100).contains(100), isTrue);
    expect(const PriceRange(min: 100).contains(99), isFalse);
    expect(const PriceRange().isAny, isTrue);
  });
}
