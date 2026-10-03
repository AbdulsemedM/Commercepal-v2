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

  /// One scrolling row per section, Amazon-style: more variety per screen
  /// than stacked rows of the same category.
  static const int _maxPerSection = 12;

  /// Largest real discount in the section, for the deals subtitle.
  static int? _maxDiscount(List<Product> products) {
    int best = 0;
    for (final Product p in products) {
      int pct = p.discountPercentage ?? 0;
      final double? o = p.originalPrice;
      if (pct <= 0 && o != null && o > p.price && p.price > 0) {
        pct = (((o - p.price) / o) * 100).round();
      }
      if (pct > best && pct < 100) best = pct;
    }
    return best > 0 ? best : null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommerceColors c = context.commerce;
    final bool isDeals = config.id == 'todays_deals';
    final List<Product> visible = products.take(_maxPerSection).toList();
    final int? upTo = isDeals ? _maxDiscount(visible) : null;
    // Empty sections are noise on the home feed; drop them entirely.
    if (visible.isEmpty) return const SizedBox.shrink();

    void seeAll() => context.push(
          '${AppRoutes.productSearch}?query=${Uri.encodeComponent(config.searchQuery)}',
        );

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: _localizedTitle(context, config),
          subtitle: upTo != null
              ? context.tr('home.deals.upTo', <String, Object?>{
                  'percent': upTo,
                })
              : null,
          leading: isDeals
              ? Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.deal,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Icon(Icons.bolt_rounded, color: c.onDeal, size: 20),
                )
              : null,
          actionLabel: context.tr('common.seeAll'),
          onAction: seeAll,
        ),
        const SizedBox(height: Spacing.xxs),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Text(
              context.tr('home.discover.empty'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          HomeProductRow(
            products: visible,
            imagePriorityBase: sectionIndex * kHomeDiscoverMaxProductsPerSection,
          ),
      ],
    );

    if (!isDeals) return content;

    // Deals sit on a tinted panel so they read as a promotion, not a row.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.xxs),
      decoration: BoxDecoration(
        color: c.dealContainer,
        borderRadius: AppRadius.lgAll,
      ),
      child: content,
    );
  }
}

/// Translated section title, falling back to the config's English title.
String _localizedTitle(BuildContext context, HomeDiscoverSectionConfig c) {
  final String key = 'home.discover.${c.id}';
  final String t = context.tr(key);
  return t == key ? c.title : t;
}
