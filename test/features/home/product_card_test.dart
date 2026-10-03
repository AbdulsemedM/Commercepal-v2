import 'package:commercepal/core/theme/theme.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(child: SizedBox(width: 160, height: 300, child: child)),
      ),
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LocalizationService.ensureInitialized();
  });

  testWidgets('derives discount badge and list price from the product',
      (tester) async {
    await tester.pumpWidget(
      _host(
        ProductCard(
          imageUrl: '',
          description: 'Headphones',
          price: '',
          product: Product(
            id: '1',
            name: 'Headphones',
            price: 80,
            originalPrice: 100,
            currency: 'ETB',
          ),
        ),
      ),
    );
    expect(find.text('-20%'), findsOneWidget);
    expect(find.textContaining('100.00'), findsOneWidget);
  });

  testWidgets('parses a pre-formatted price when no product is given',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const ProductCard(
          imageUrl: '',
          description: 'Charger',
          price: 'ETB 1,250.00',
          originalPrice: 'ETB 2,500.00',
        ),
      ),
    );
    expect(find.textContaining('1,250', findRichText: true), findsOneWidget);
    expect(find.text('-50%'), findsOneWidget);
  });

  testWidgets('shows out-of-stock overlay instead of discount',
      (tester) async {
    await tester.pumpWidget(
      _host(
        ProductCard(
          imageUrl: '',
          description: 'Bag',
          price: '',
          product: Product(
            id: '2',
            name: 'Bag',
            price: 10,
            discountPercentage: 10,
            currency: 'ETB',
            isAvailable: false,
          ),
        ),
      ),
    );
    expect(find.text('Out of stock'), findsOneWidget);
    expect(find.text('-10%'), findsNothing);
  });
}
