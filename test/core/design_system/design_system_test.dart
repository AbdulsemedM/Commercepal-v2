import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/theme/theme.dart';
import 'package:commercepal/core/theme/theme_controller.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LocalizationService.ensureInitialized();
  });

  group('AppTheme', () {
    test('light and dark expose CommerceColors', () {
      expect(AppTheme.light.extension<CommerceColors>(), isNotNull);
      expect(AppTheme.dark.extension<CommerceColors>(), isNotNull);
      expect(AppTheme.light.colorScheme.primary, AppColors.maroon);
      expect(AppTheme.dark.brightness, Brightness.dark);
    });

    test('uses bundled Inter with script fallbacks', () {
      final TextStyle body = AppTheme.light.textTheme.bodyMedium!;
      expect(body.fontFamily, 'Inter');
      expect(body.fontFamilyFallback, contains('NotoSansEthiopic'));
      expect(body.fontFamilyFallback, contains('NotoSansArabic'));
    });
  });

  group('ThemeController', () {
    test('round-trips every mode, including system', () {
      for (final ThemeMode m in ThemeMode.values) {
        expect(
          ThemeController.parseThemeMode(
            ThemeController.serializeThemeMode(m),
          ),
          m,
        );
      }
    });
  });

  group('PriceTag', () {
    test('discountPercent is rounded and only for real discounts', () {
      expect(
        const PriceTag(amount: 80, currency: 'ETB', originalAmount: 100)
            .discountPercent,
        20,
      );
      expect(
        const PriceTag(amount: 100, currency: 'ETB', originalAmount: 100)
            .discountPercent,
        isNull,
      );
      expect(
        const PriceTag(amount: 120, currency: 'ETB', originalAmount: 100)
            .discountPercent,
        isNull,
      );
      expect(
        const PriceTag(amount: 99.9, currency: 'ETB', originalAmount: 100)
            .discountPercent,
        isNull,
      );
    });

    testWidgets('renders amount, list price and badge', (tester) async {
      await tester.pumpWidget(
        _host(
          const PriceTag(
            amount: 1899.5,
            currency: 'ETB',
            originalAmount: 2500,
          ),
        ),
      );
      expect(find.textContaining('1,899', findRichText: true), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('ETB 2,500.00'), findsOneWidget);
      expect(find.text('-24%'), findsOneWidget);
    });

    testWidgets('hides .00 decimals and badge without discount',
        (tester) async {
      await tester.pumpWidget(
        _host(const PriceTag(amount: 1200, currency: 'USD')),
      );
      expect(find.textContaining('1,200', findRichText: true), findsOneWidget);
      expect(find.text('00'), findsNothing);
      expect(find.byType(AppBadge), findsNothing);
    });
  });

  group('RatingStars', () {
    test('formatCount abbreviates', () {
      expect(RatingStars.formatCount(999), '999');
      expect(RatingStars.formatCount(1000), '1k');
      expect(RatingStars.formatCount(1234), '1.2k');
      expect(RatingStars.formatCount(2500000), '2.5M');
    });

    testWidgets('shows value and count', (tester) async {
      await tester.pumpWidget(
        _host(const RatingStars(rating: 4.36, reviewCount: 1520)),
      );
      expect(find.text('4.4'), findsOneWidget);
      expect(find.text('(1.5k)'), findsOneWidget);
    });
  });

  group('AppButton', () {
    testWidgets('fires onPressed', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(AppButton.primary(label: 'Add to cart', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Add to cart'));
      expect(taps, 1);
    });

    testWidgets('loading blocks taps and shows spinner', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          AppButton.primary(
            label: 'Pay',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(AppButton));
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('QuantityStepper', () {
    testWidgets('increments and respects min', (tester) async {
      int value = 1;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => _host(
            QuantityStepper(
              value: value,
              onChanged: (int v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.remove_rounded));
      expect(value, 1);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(value, 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows trash at min when onRemove is set', (tester) async {
      bool removed = false;
      await tester.pumpWidget(
        _host(
          QuantityStepper(
            value: 1,
            onChanged: (_) {},
            onRemove: () => removed = true,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      expect(removed, isTrue);
    });
  });

  group('CountBadge', () {
    testWidgets('hidden at zero, capped above max', (tester) async {
      await tester.pumpWidget(
        _host(const CountBadge(count: 0, child: Icon(Icons.shopping_cart))),
      );
      expect(find.text('0'), findsNothing);

      await tester.pumpWidget(
        _host(const CountBadge(count: 150, child: Icon(Icons.shopping_cart))),
      );
      await tester.pumpAndSettle();
      expect(find.text('99+'), findsOneWidget);
    });
  });

  testWidgets('components render in dark theme', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PriceTag(amount: 10, currency: 'ETB', originalAmount: 20),
            RatingStars(rating: 3.5, reviewCount: 4),
            AppBadge(label: 'New', tone: AppBadgeTone.brand),
            SizedBox(width: 160, child: ProductCardShimmer()),
          ],
        ),
        theme: AppTheme.dark,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
