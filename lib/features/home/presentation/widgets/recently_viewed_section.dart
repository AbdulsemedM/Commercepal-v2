import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/home/bloc/recently_viewed_bloc.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'product_card.dart';

class RecentlyViewedSection extends StatelessWidget {
  const RecentlyViewedSection({super.key});

  static String _formatPrice(Product product) {
    final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
    final prefix = symbol.length > 1 ? '$symbol ' : symbol;
    return '$prefix${MoneyFormatter.formatAmount(product.price)}';
  }

  static String? _formatOriginalPrice(Product product) {
    double? original = product.originalPrice;
    // Derive from discount when the API omits originalPrice.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: HomeSectionHeader(
            title: LocalizationService.t(context, 'home.recentlyViewed.title'),
          ),
        ),
        const SizedBox(height: Spacing.md),
        BlocBuilder<RecentlyViewedBloc, RecentlyViewedState>(
          builder: (context, state) {
            if (state is RecentlyViewedLoading) {
              return _buildLoading(context);
            }
            if (state is RecentlyViewedError) {
              return _buildError(context, state.message);
            }
            if (state is RecentlyViewedLoaded) {
              if (state.products.isEmpty) {
                return _buildEmpty(context);
              }
              return _buildProductList(context, state.products);
            }
            return _buildEmpty(context);
          },
        ),
        const SizedBox(height: Spacing.xl),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 180,
            child: Shimmer.fromColors(
              baseColor: scheme.surfaceContainerHighest,
              highlightColor: scheme.surface,
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: AppDecorations.cardBorderRadius,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
      child: Center(
        child: Text(
          'No recently viewed products',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<Product> products) {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 180,
            child: ProductCard(
              product: product,
              productId: product.id,
              imageUrl: product.imageUrl ?? '',
              description: product.name,
              price: _formatPrice(product),
              originalPrice: _formatOriginalPrice(product),
              rating: product.rating,
              reviewCount: product.reviewCount,
              discountPercentage: product.discountPercentage,
              currency: product.currency,
              showProgressBar: false,
            ),
          );
        },
      ),
    );
  }
}
