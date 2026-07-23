import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/features/home/bloc/home_wholesale_bloc.dart';
import 'package:commercepal/features/home/data/home_wholesale_config.dart';
import 'package:commercepal/features/home/presentation/widgets/home_product_rows.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/services/localization_service.dart';

class HomeWholesaleSection extends StatelessWidget {
  const HomeWholesaleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeWholesaleBloc, HomeWholesaleState>(
      builder: (context, state) {
        if (state is HomeWholesaleLoading || state is HomeWholesaleInitial) {
          return const _WholesaleLoading();
        }
        if (state is HomeWholesaleError) {
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
        if (state is HomeWholesaleLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var i = 0; i < kHomeWholesaleSections.length; i++) ...[
                if (i > 0) const SizedBox(height: Spacing.lg),
                _WholesaleCategoryBlock(
                  config: kHomeWholesaleSections[i],
                  products: state.sections[kHomeWholesaleSections[i].id] ??
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

class _WholesaleCategoryBlock extends StatelessWidget {
  const _WholesaleCategoryBlock({
    required this.config,
    required this.products,
  });

  final HomeWholesaleSectionConfig config;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final rows = chunkHomeProducts(
      products,
      maxProducts: config.pageSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: HomeSectionHeader(
            title: LocalizationService.t(context, config.titleKey),
            actionLabel: LocalizationService.t(context, 'home.categories.seeAll'),
            onAction: () {
              context.push(
                '${AppRoutes.productSearch}?query=${Uri.encodeComponent(config.searchQuery)}&accountType=${Uri.encodeComponent(config.accountType)}',
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Text(
              LocalizationService.t(context, 'home.wholesale.emptySection'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          for (final row in rows) HomeProductRow(products: row),
      ],
    );
  }
}

class _WholesaleLoading extends StatelessWidget {
  const _WholesaleLoading();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var s = 0; s < 3; s++) ...[
          if (s > 0) const SizedBox(height: Spacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: kHomeProductRowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: kHomeProductRowVerticalInset,
              ),
              itemCount: kHomeProductsPerRow,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
              itemBuilder: (_, __) => Container(
                width: kHomeProductCardWidth,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: AppDecorations.cardBorderRadius,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
