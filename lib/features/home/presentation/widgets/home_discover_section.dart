import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
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
          return const SliverToBoxAdapter(child: HomeSectionsSkeleton());
        }
        if (state is HomeDiscoverError) {
          return SliverToBoxAdapter(
            child: AppEmptyState(
              compact: true,
              isError: true,
              icon: Icons.wifi_off_rounded,
              title: context.tr('common.somethingWentWrong'),
              subtitle: context.tr('common.checkConnection'),
              primaryLabel: context.tr('common.retry'),
              onPrimary: () =>
                  context.read<HomeDiscoverBloc>().add(FetchHomeDiscover()),
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
          return SliverList.separated(
            itemCount: kHomeDiscoverSections.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.lg),
            itemBuilder: (BuildContext context, int i) =>
                _DiscoverCategoryBlock(
              sectionIndex: i,
              config: kHomeDiscoverSections[i],
              products:
                  state.sections[kHomeDiscoverSections[i].id] ?? <Product>[],
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
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
            title: _localizedTitle(context, config),
            actionLabel: context.tr('common.seeAll'),
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
              context.tr('home.discover.empty'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
            HomeProductRow(
              products: rows[rowIndex],
              imagePriorityBase:
                  sectionIndex * kHomeDiscoverMaxProductsPerSection +
                      rowIndex * kHomeProductsPerRow,
            ),
      ],
    );
  }
}

/// Translated section title, falling back to the config's English title.
String _localizedTitle(BuildContext context, HomeDiscoverSectionConfig c) {
  final String key = 'home.discover.${c.id}';
  final String t = context.tr(key);
  return t == key ? c.title : t;
}
