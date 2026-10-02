import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/category_image_assets.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/categories/data/models/category.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/services/localization_service.dart';

/// "Shop by category" — Amazon-style cards, each a category with a 2×2
/// grid of its subcategories and a "See more" link.
class CategoryQuadCards extends StatelessWidget {
  const CategoryQuadCards({super.key, this.maxCards = 4});

  final int maxCards;

  static void _search(BuildContext context, String term) {
    context.push(
      '${AppRoutes.productSearch}?query=${Uri.encodeComponent(term.trim())}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (BuildContext context, CategoriesState state) {
        final Widget body;
        if (state is CategoriesLoaded) {
          final List<Category> cats = state.categories
              .where((Category c) => c.subCategories.isNotEmpty)
              .take(maxCards)
              .toList();
          if (cats.isEmpty) return const SizedBox.shrink();
          body = _grid(
            context,
            <Widget>[for (final Category c in cats) _QuadCard(category: c)],
          );
        } else if (state is CategoriesError) {
          return AppEmptyState(
            compact: true,
            isError: true,
            icon: Icons.category_outlined,
            title: context.tr('common.somethingWentWrong'),
            primaryLabel: context.tr('common.retry'),
            onPrimary: () =>
                context.read<CategoriesBloc>().add(FetchCategories()),
          );
        } else {
          body = _grid(
            context,
            List<Widget>.generate(4, (_) => const _QuadCardSkeleton()),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(
              title: context.tr('home.shopByCategory'),
              actionLabel: context.tr('common.seeAll'),
              onAction: () => context
                  .findAncestorStateOfType<DashboardScreenState>()
                  ?.changeTab(1),
            ),
            const SizedBox(height: Spacing.xs),
            body,
          ],
        );
      },
    );
  }

  Widget _grid(BuildContext context, List<Widget> cards) {
    // Two columns; cards share one structure so rows line up.
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < cards.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: cards[i]),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: i + 1 < cards.length ? cards[i + 1] : const SizedBox(),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: Spacing.sm),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _QuadCard extends StatelessWidget {
  const _QuadCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<SubCategory> subs = category.subCategories.take(4).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.sm,
          Spacing.sm,
          Spacing.sm,
          Spacing.xxs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            _TwoByTwo(
              children: <Widget>[
                for (final SubCategory s in subs)
                  _QuadTile(
                    label: s.name,
                    image: _SubImage(name: s.name, url: s.imageUrl),
                    onTap: () => CategoryQuadCards._search(context, s.name),
                  ),
                // Pad short categories with the category itself.
                for (int i = subs.length; i < 4; i++)
                  _QuadTile(
                    label: category.name,
                    image: _SubImage(name: category.name, url: category.imageUrl),
                    onTap: () =>
                        CategoryQuadCards._search(context, category.name),
                  ),
              ],
            ),
            AppButton.text(
              label: context.tr('home.seeMore'),
              size: AppButtonSize.small,
              onPressed: () => CategoryQuadCards._search(context, category.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuadTile extends StatelessWidget {
  const _QuadTile({
    required this.label,
    required this.image,
    required this.onTap,
  });

  final String label;
  final Widget image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(borderRadius: AppRadius.smAll, child: image),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubImage extends StatelessWidget {
  const _SubImage({required this.name, this.url});

  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool hasUrl = url != null && url!.isNotEmpty;
    final String? asset = CategoryImageAssets.assetPathForName(name);
    final Widget fallback = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Icon(
        CategoryImageAssets.iconForName(name),
        color: scheme.onSurfaceVariant,
      ),
    );
    final int cache = (90 * MediaQuery.devicePixelRatioOf(context)).round();

    Widget network() => AppNetworkImage(
          url: url!,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: cache,
          errorWidget: fallback,
        );

    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        cacheWidth: cache,
        errorBuilder: (_, __, ___) => hasUrl ? network() : fallback,
      );
    }
    return hasUrl ? network() : fallback;
  }
}

class _QuadCardSkeleton extends StatelessWidget {
  const _QuadCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const ShimmerLoading(width: 90, height: 14),
            const SizedBox(height: Spacing.xs),
            _TwoByTwo(
              children: List<Widget>.generate(
                4,
                (_) => const AspectRatio(
                  aspectRatio: 1,
                  child: ShimmerLoading(),
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            const ShimmerLoading(width: 60, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Exactly four children laid out 2×2 without a scrollable.
class _TwoByTwo extends StatelessWidget {
  const _TwoByTwo({required this.children}) : assert(children.length == 4);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    Widget row(int a) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: children[a]),
            const SizedBox(width: Spacing.xs),
            Expanded(child: children[a + 1]),
          ],
        );
    return Column(
      children: <Widget>[row(0), const SizedBox(height: Spacing.xs), row(2)],
    );
  }
}
