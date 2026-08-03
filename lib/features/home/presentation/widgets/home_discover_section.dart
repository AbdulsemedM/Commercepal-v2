import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/features/home/bloc/home_discover_bloc.dart';
import 'package:commercepal/features/home/data/home_discover_config.dart';
import 'package:commercepal/features/home/presentation/widgets/home_image_prefetch.dart';
import 'package:commercepal/features/home/presentation/widgets/home_product_rows.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:commercepal/features/products/data/models/product.dart';

class HomeDiscoverSection extends StatelessWidget {
  const HomeDiscoverSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeDiscoverBloc, HomeDiscoverState>(
      listenWhen: (HomeDiscoverState previous, HomeDiscoverState current) =>
          current is HomeDiscoverLoaded && previous is! HomeDiscoverLoaded,
      listener: (BuildContext context, HomeDiscoverState state) {
        if (state is HomeDiscoverLoaded) {
          prefetchHomeCatalogImages(
            sectionIdsInOrder: kHomeDiscoverSections
                .map((HomeDiscoverSectionConfig c) => c.id)
                .toList(),
            sections: state.sections,
            maxProductsPerSection: kHomeDiscoverMaxProductsPerSection,
          );
        }
      },
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
          // Covers cache-hit first frame where listenWhen may not fire.
          prefetchHomeCatalogImages(
            sectionIdsInOrder: kHomeDiscoverSections
                .map((HomeDiscoverSectionConfig c) => c.id)
                .toList(),
            sections: state.sections,
            maxProductsPerSection: kHomeDiscoverMaxProductsPerSection,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var i = 0; i < kHomeDiscoverSections.length; i++) ...[
                if (i > 0) const SizedBox(height: Spacing.lg),
                _DiscoverCategoryBlock(
                  sectionIndex: i,
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
    required this.sectionIndex,
    required this.config,
    required this.products,
  });

  final int sectionIndex;
  final HomeDiscoverSectionConfig config;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final List<List<Product>> rows = chunkHomeProducts(
      products,
      maxProducts: kHomeDiscoverMaxProductsPerSection,
    );

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
          for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
            HomeProductRow(
              products: rows[rowIndex],
              imagePriorityBase: sectionIndex * kHomeDiscoverMaxProductsPerSection +
                  rowIndex * kHomeProductsPerRow,
            ),
      ],
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
          for (var row = 0; row < 2; row++)
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
