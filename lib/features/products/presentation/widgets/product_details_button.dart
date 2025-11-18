import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class ProductDetailsButton extends StatelessWidget {
  const ProductDetailsButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'productDetail.productDetailsReviews'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

