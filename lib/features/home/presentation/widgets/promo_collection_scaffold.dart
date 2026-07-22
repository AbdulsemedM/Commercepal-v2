import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/core/widgets/app_empty_state.dart';
import 'package:commercepal/core/widgets/shimmer_loading.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/services/navigation_service.dart';

/// Shared chrome for banner promo collection screens.
class PromoCollectionScaffold extends StatelessWidget {
  const PromoCollectionScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.heroGradient,
    required this.heroIcon,
    required this.badgeLabel,
    required this.isLoading,
    required this.errorMessage,
    required this.products,
    required this.onRefresh,
    this.emptyTitle = 'Nothing here yet',
    this.emptySubtitle = 'Check back soon for new deals.',
  });

  final String title;
  final String subtitle;
  final LinearGradient heroGradient;
  final IconData heroIcon;
  final String badgeLabel;
  final bool isLoading;
  final String? errorMessage;
  final List<Product> products;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    CartBloc? cartBloc;
    try {
      cartBloc = context.read<CartBloc>();
    } catch (_) {
      cartBloc = null;
    }

    final Widget body = Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _HeroHeader(
                  title: title,
                  subtitle: subtitle,
                  heroGradient: heroGradient,
                  heroIcon: heroIcon,
                  badgeLabel: badgeLabel,
                  productCount: isLoading ? null : products.length,
                ),
              ),
              if (isLoading)
                SliverPadding(
                  padding: const EdgeInsets.all(Spacing.md),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: Spacing.md,
                      mainAxisSpacing: Spacing.md,
                      childAspectRatio: 0.52,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) =>
                          const ProductCardShimmer(),
                      childCount: 6,
                    ),
                  ),
                )
              else if (errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: Icons.wifi_off_outlined,
                    title: errorMessage!,
                    primaryLabel: 'Retry',
                    onPrimary: () => onRefresh(),
                  ),
                )
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: Icons.local_offer_outlined,
                    title: emptyTitle,
                    subtitle: emptySubtitle,
                    primaryLabel: 'Back to Home',
                    onPrimary: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        NavigationService.instance
                            .navigateToDashboardTab(context, 0);
                      }
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.sm,
                    Spacing.md,
                    Spacing.xl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: Spacing.md,
                      mainAxisSpacing: Spacing.md,
                      childAspectRatio: 0.52,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final Product product = products[index];
                        return ProductCard(
                          key: ValueKey('promo_${product.id}_$index'),
                          product: product,
                          productId: product.id,
                          imageUrl: product.imageUrl ?? '',
                          description: product.name,
                          price: MoneyFormatter.format(
                            product.price,
                            product.currency,
                          ),
                          originalPrice: product.originalPrice != null
                              ? MoneyFormatter.format(
                                  product.originalPrice!,
                                  product.currency,
                                )
                              : null,
                          rating: product.rating,
                          reviewCount: product.reviewCount,
                          discountPercentage: product.discountPercentage,
                          fillCell: true,
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (cartBloc == null) return body;
    return BlocProvider.value(value: cartBloc, child: body);
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.heroGradient,
    required this.heroIcon,
    required this.badgeLabel,
    required this.productCount,
  });

  final String title;
  final String subtitle;
  final LinearGradient heroGradient;
  final IconData heroIcon;
  final String badgeLabel;
  final int? productCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.md,
      ),
      decoration: BoxDecoration(
        gradient: heroGradient,
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        boxShadow: AppDecorations.softCardShadow(AppColors.primary),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -24,
            top: -28,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.md,
              Spacing.md,
              Spacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                      ),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          color: AppColors.onSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(heroIcon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          if (productCount != null) ...[
                            const SizedBox(height: Spacing.sm),
                            Text(
                              '$productCount products',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
