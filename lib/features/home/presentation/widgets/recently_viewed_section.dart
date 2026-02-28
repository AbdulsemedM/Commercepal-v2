import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/home/bloc/recently_viewed_bloc.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'product_card.dart';

class RecentlyViewedSection extends StatelessWidget {
  const RecentlyViewedSection({super.key});

  static String _formatPrice(Product product) {
    final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
    final prefix = symbol.length > 1 ? '$symbol ' : symbol;
    return '$prefix${product.price.toStringAsFixed(2)}';
  }

  static String? _formatOriginalPrice(Product product) {
    if (product.originalPrice == null) return null;
    final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
    final prefix = symbol.length > 1 ? '$symbol ' : symbol;
    return '$prefix${product.originalPrice!.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RecentlyViewedBloc()..add(FetchRecentlyViewed()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  LocalizationService.t(context, 'home.recentlyViewed.title'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ],
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
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 160,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
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
                color: Colors.grey[600],
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
                color: Colors.grey[500],
              ),
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<Product> products) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 160,
            child: ProductCard(
              productId: product.id,
              imageUrl: product.imageUrl ?? '',
              description: product.name,
              price: _formatPrice(product),
              originalPrice: _formatOriginalPrice(product),
              rating: product.rating,
              reviewCount: product.reviewCount,
              discountPercentage: product.discountPercentage,
              showProgressBar: false,
            ),
          );
        },
      ),
    );
  }
}
