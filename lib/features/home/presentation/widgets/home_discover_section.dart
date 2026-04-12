import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/features/home/bloc/home_discover_bloc.dart';
import 'package:commercepal/features/home/data/home_discover_config.dart';
import 'package:commercepal/features/products/data/models/product.dart';

import 'compact_discover_product_tile.dart';

/// 5×4 grid layout: explicit height avoids unbounded-height render errors inside
/// vertical `SingleChildScrollView` → `Column` → horizontal scroll.
class _DiscoverGridMetrics {
  const _DiscoverGridMetrics({
    required this.gridWidth,
    required this.gridHeight,
    required this.childAspectRatio,
    required this.spacing,
  });

  final double gridWidth;
  final double gridHeight;
  final double childAspectRatio;
  final double spacing;
}

_DiscoverGridMetrics _discoverGridMetrics(double parentMaxWidth) {
  const int columns = 5;
  const int rows = 4;
  const double spacing = 8;
  const double minCellWidth = 84;
  final double minGridWidth = columns * minCellWidth + (columns - 1) * spacing;
  final double gridWidth = math.max(parentMaxWidth, minGridWidth);
  final double cellWidth = (gridWidth - (columns - 1) * spacing) / columns;
  /// Slightly lower ratio => taller cells => more room for title/price (avoids overflow).
  const double childAspectRatio = 0.68;
  final double cellHeight = cellWidth / childAspectRatio;
  final double gridHeight = rows * cellHeight + (rows - 1) * spacing;
  return _DiscoverGridMetrics(
    gridWidth: gridWidth,
    gridHeight: gridHeight,
    childAspectRatio: childAspectRatio,
    spacing: spacing,
  );
}

class HomeDiscoverSection extends StatelessWidget {
  const HomeDiscoverSection({super.key});

  static String _formatPrice(Product product) {
    final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
    final prefix = symbol.length > 1 ? '$symbol ' : symbol;
    return '$prefix${MoneyFormatter.formatAmount(product.price)}';
  }

  static String? _formatOriginalPrice(Product product) {
    if (product.originalPrice == null) return null;
    final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
    final prefix = symbol.length > 1 ? '$symbol ' : symbol;
    return '$prefix${MoneyFormatter.formatAmount(product.originalPrice!)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeDiscoverBloc()..add(FetchHomeDiscover()),
      child: BlocBuilder<HomeDiscoverBloc, HomeDiscoverState>(
        builder: (context, state) {
          if (state is HomeDiscoverLoading || state is HomeDiscoverInitial) {
            return _DiscoverLoading();
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
                        color: Colors.grey[600],
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
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  config.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push(
                    '${AppRoutes.productSearch}?query=${Uri.encodeComponent(config.searchQuery)}',
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double parentW = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;

            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Text(
                  'No products in this category right now.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              );
            }

            final _DiscoverGridMetrics m = _discoverGridMetrics(parentW);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: SizedBox(
                width: m.gridWidth,
                height: m.gridHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: m.spacing,
                    crossAxisSpacing: m.spacing,
                    childAspectRatio: m.childAspectRatio,
                  ),
                  itemCount: 20,
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= products.length) {
                      return _EmptyDiscoverSlot();
                    }
                    final Product p = products[index];
                    return CompactDiscoverProductTile(
                      productId: p.id,
                      imageUrl: p.imageUrl ?? '',
                      title: p.name,
                      price: HomeDiscoverSection._formatPrice(p),
                      originalPrice: HomeDiscoverSection._formatOriginalPrice(p),
                      discountPercentage: p.discountPercentage,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyDiscoverSlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 20,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _DiscoverLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final double parentW = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;
              final _DiscoverGridMetrics m = _discoverGridMetrics(parentW);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: SizedBox(
                  width: m.gridWidth,
                  height: m.gridHeight,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: m.spacing,
                      crossAxisSpacing: m.spacing,
                      childAspectRatio: m.childAspectRatio,
                    ),
                    itemCount: 20,
                    itemBuilder: (_, __) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
