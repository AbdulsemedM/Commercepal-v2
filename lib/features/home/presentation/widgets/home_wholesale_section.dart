import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/home/bloc/home_wholesale_bloc.dart';
import 'package:commercepal/features/home/data/home_wholesale_config.dart';
import 'package:commercepal/features/home/presentation/widgets/home_image_prefetch.dart';
import 'package:commercepal/features/home/presentation/widgets/home_product_rows.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/services/localization_service.dart';

class HomeWholesaleSection extends StatelessWidget {
  const HomeWholesaleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeWholesaleBloc, HomeWholesaleState>(
      listenWhen: (HomeWholesaleState previous, HomeWholesaleState current) =>
          current is HomeWholesaleLoaded && previous is! HomeWholesaleLoaded,
      listener: (BuildContext context, HomeWholesaleState state) {
        if (state is HomeWholesaleLoaded) {
          // Use a stable stride so section order matches discover-style priorities.
          prefetchHomeCatalogImages(
            sectionIdsInOrder: kHomeWholesaleSections
                .map((HomeWholesaleSectionConfig c) => c.id)
                .toList(),
            sections: state.sections,
            maxProductsPerSection: kHomeDiscoverMaxProductsPerSection,
          );
        }
      },
      builder: (context, state) {
        if (state is HomeWholesaleLoading || state is HomeWholesaleInitial) {
          return const SliverToBoxAdapter(child: HomeSectionsSkeleton());
        }
        if (state is HomeWholesaleError) {
          return SliverToBoxAdapter(
            child: AppEmptyState(
              compact: true,
              isError: true,
              icon: Icons.wifi_off_rounded,
              title: context.tr('common.somethingWentWrong'),
              subtitle: context.tr('common.checkConnection'),
              primaryLabel: context.tr('common.retry'),
              onPrimary: () =>
                  context.read<HomeWholesaleBloc>().add(FetchHomeWholesale()),
            ),
          );
        }
        if (state is HomeWholesaleLoaded) {
          prefetchHomeCatalogImages(
            sectionIdsInOrder: kHomeWholesaleSections
                .map((HomeWholesaleSectionConfig c) => c.id)
                .toList(),
            sections: state.sections,
            maxProductsPerSection: kHomeDiscoverMaxProductsPerSection,
          );
          return SliverList.separated(
            itemCount: kHomeWholesaleSections.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.lg),
            itemBuilder: (BuildContext context, int i) =>
                _WholesaleCategoryBlock(
              sectionIndex: i,
              config: kHomeWholesaleSections[i],
              products:
                  state.sections[kHomeWholesaleSections[i].id] ?? <Product>[],
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class _WholesaleCategoryBlock extends StatelessWidget {
  const _WholesaleCategoryBlock({
    required this.sectionIndex,
    required this.config,
    required this.products,
  });

  final int sectionIndex;
  final HomeWholesaleSectionConfig config;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    // One scrolling row per section (see home discover).
    final List<Product> visible = products.take(12).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: HomeSectionHeader(
            title: LocalizationService.t(context, config.titleKey),
            actionLabel: context.tr('common.seeAll'),
            onAction: () {
              context.push(
                '${AppRoutes.productSearch}?query=${Uri.encodeComponent(config.searchQuery)}&accountType=${Uri.encodeComponent(config.accountType)}',
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (visible.isEmpty)
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
          HomeProductRow(
            products: visible,
            imagePriorityBase:
                sectionIndex * kHomeDiscoverMaxProductsPerSection,
          ),
      ],
    );
  }
}
