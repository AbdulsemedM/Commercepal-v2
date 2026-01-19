import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'product_card.dart';

class RecentlyViewedSection extends StatelessWidget {
  const RecentlyViewedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header
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
              InkWell(
                onTap: () {
                  // TODO: Navigate to all recently viewed
                },
                child: Text(
                  LocalizationService.t(context, 'home.recentlyViewed.seeAll'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        // Product cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ProductCard(
                  imageUrl: '',
                  description: 'Apple-Watch Ultra-2-49-mm-titanium-smart-watch',
                  price: '\$504.18',
                  showProgressBar: false,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: ProductCard(
                  imageUrl: '',
                  description: 'iPad Pro 13 Inch M4 MQR243/A Titanium (2025)',
                  price: '\$1100.18',
                  showProgressBar: false,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xl),
      ],
    );
  }
}

