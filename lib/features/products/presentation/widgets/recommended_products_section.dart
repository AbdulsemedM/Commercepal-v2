import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import '../../data/models/recommended_product.dart';

class RecommendedProductsSection extends StatelessWidget {
  const RecommendedProductsSection({
    super.key,
    required this.products,
    this.onViewAllTap,
  });

  final List<RecommendedProduct> products;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You May Also Like',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (products.length > 4 && onViewAllTap != null)
                  TextButton(
                    onPressed: onViewAllTap,
                    child: const Text('View All'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: Spacing.sm),
                  child: ProductCard(
                    productId: product.id,
                    imageUrl: product.images.thumbnail,
                    description: product.title,
                    price: product.pricing.formattedCurrentPrice,
                    rating: product.meta.rating,
                    reviewCount: product.meta.reviewCount,
                    originalPrice: product.pricing.isOnDiscount
                        ? product.pricing.formattedOriginalPrice
                        : null,
                    discountPercentage: product.pricing.isOnDiscount
                        ? product.pricing.discountPercentage.round()
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
