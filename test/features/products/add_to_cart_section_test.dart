import 'package:commercepal/core/theme/theme.dart';
import 'package:commercepal/features/products/presentation/widgets/add_to_cart_section.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget bar) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(bottomNavigationBar: bar),
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LocalizationService.ensureInitialized();
  });

  testWidgets('buy now and add to cart fire their callbacks', (tester) async {
    int adds = 0, buys = 0;
    await tester.pumpWidget(
      _host(
        AddToCartSection(
          isInCart: false,
          onAddToCart: () => adds++,
          onBuyNow: () => buys++,
        ),
      ),
    );
    await tester.tap(find.text('Buy now'));
    await tester.tap(find.text('Add to cart'));
    expect(buys, 1);
    expect(adds, 1);
  });

  testWidgets('unavailable hides buy now and disables add', (tester) async {
    int adds = 0;
    await tester.pumpWidget(
      _host(
        AddToCartSection(
          isInCart: false,
          canAddToCart: false,
          onAddToCart: () => adds++,
          onBuyNow: () {},
        ),
      ),
    );
    expect(find.text('Buy now'), findsNothing);
    await tester.tap(find.text('Unavailable'));
    expect(adds, 0);
  });

  testWidgets('in-cart state offers View cart', (tester) async {
    bool viewed = false;
    await tester.pumpWidget(
      _host(
        AddToCartSection(
          isInCart: true,
          onAddToCart: () {},
          onViewCart: () => viewed = true,
        ),
      ),
    );
    expect(find.text('In your cart'), findsOneWidget);
    await tester.tap(find.text('View cart'));
    expect(viewed, isTrue);
  });
}
