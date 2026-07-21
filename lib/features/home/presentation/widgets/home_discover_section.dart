import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/features/home/bloc/home_discover_bloc.dart';
import 'package:commercepal/features/home/data/home_discover_config.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/data/models/product.dart';

/// Max products shown per category on Home (4 rows x 5).
const int _kProductsPerRow = 5;
const int _kMaxRows = 4;
const int _kMaxProductsPerSection = _kProductsPerRow * _kMaxRows;
const double _kCardWidth = 150;
const double _kRowHeight = 290;

List<List<Product>> _chunkProducts(List<Product> products) {
  final int capped = products.length.clamp(0, _kMaxProductsPerSection);
  final List<Product> slice = products.take(capped).toList();
  final List<List<Product>> rows = <List<Product>>[];
  for (var i = 0; i < slice.length; i += _kProductsPerRow) {
    final int end = (i + _kProductsPerRow).clamp(0, slice.length);
    rows.add(slice.sublist(i, end));
  }
  return rows;
}

class HomeDiscoverSection extends StatelessWidget {
  const HomeDiscoverSection({super.key});

  static String _formatPrice(Product product) {
    final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
    final prefix = symbol.length > 1 ? '$symbol ' : symbol;
    return '$prefix${MoneyFormatter.formatAmount(product.price)}';
  }

  static String? _formatOriginalPrice(Product product) {
    double? original = product.originalPrice;
    // Search API often omits originalPrice; derive it from the discount so
    // both prices still show on discounted products.
    if (original == null &&
        product.discountPercentage != null &&
        product.discountPercentage! > 0 &&
        product.discountPercentage! < 100) {
      original = product.price / (1 - product.discountPercentage! / 100);
    }
    if (original == null || original <= product.price) return null;
    final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
    final prefix = symbol.length > 1 ? '$symbol ' : symbol;
    return '$prefix${MoneyFormatter.formatAmount(original)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDiscoverBloc, HomeDiscoverState>(
      builder: (context, state) {
        if (state is HomeDiscoverLoading || state is HomeDiscoverInitial) {
          return const _DiscoverLoading();
        }
        if (state is HomeDiscoverError) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            child: Center(
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          );
        }
        if (state is HomeDiscoverLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var i = 0; i < kHomeDiscoverSections.length; i++) ...[
                if (i > 0) const SizedBox(height: Spacing.lg),
                _DiscoverCategoryBlock(
                  config: kHomeDiscoverSections[i],
                  products: state.sections[kHomeDiscoverSections[i].id] ??
                      <Product>[],
                ),
              ],
              const SizedBox(height: Spacing.md),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _DiscoverCategoryBlock extends StatelessWidget {
  const _DiscoverCategoryBlock({
    required this.config,
    required this.products,
  });

  final HomeDiscoverSectionConfig config;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final List<List<Product>> rows = _chunkProducts(products);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: HomeSectionHeader(
            title: config.title,
            actionLabel: 'See more',
            onAction: () {
              context.push(
                '${AppRoutes.productSearch}?query=${Uri.encodeComponent(config.searchQuery)}',
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Text(
              'No products in this category right now.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: Spacing.sm),
            _DiscoverProductRow(products: rows[r]),
          ],
      ],
    );
  }
}

class _DiscoverProductRow extends StatelessWidget {
  const _DiscoverProductRow({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final Product p = products[index];
          return SizedBox(
            width: _kCardWidth,
            child: ProductCard(
              product: p,
              productId: p.id,
              imageUrl: p.imageUrl ?? '',
              description: p.name,
              price: HomeDiscoverSection._formatPrice(p),
              originalPrice: HomeDiscoverSection._formatOriginalPrice(p),
              rating: p.rating,
              reviewCount: p.reviewCount,
              discountPercentage: p.discountPercentage,
              currency: p.currency,
            ),
          );
        },
      ),
    );
  }
}

class _DiscoverLoading extends StatelessWidget {
  const _DiscoverLoading();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var s = 0; s < 4; s++) ...[
          if (s > 0) const SizedBox(height: Spacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          for (var row = 0; row < _kMaxRows; row++) ...[
            if (row > 0) const SizedBox(height: Spacing.sm),
            SizedBox(
              height: _kRowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                itemCount: _kProductsPerRow,
                separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                itemBuilder: (_, __) => Container(
                  width: _kCardWidth,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: AppDecorations.cardBorderRadius,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
