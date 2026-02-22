import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class SpecialOfferSection extends StatelessWidget {
  const SpecialOfferSection({
    super.key,
    required this.sold,
    required this.inStock,
  });

  final int sold;
  final int inStock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Text(
            '${LocalizationService.t(context, 'productDetail.specialOffer')}:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: sold / (sold + inStock),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.success,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          // Sold/In Stock info
          Text(
            '${LocalizationService.t(context, 'home.dealOfDay.sold')}: $sold ${LocalizationService.t(context, 'home.dealOfDay.inStock')}: $inStock',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

