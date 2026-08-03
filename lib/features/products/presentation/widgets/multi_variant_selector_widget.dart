import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import '../../data/models/variant.dart';

class MultiVariantSelectorWidget extends StatelessWidget {
  const MultiVariantSelectorWidget({
    super.key,
    required this.variants,
    required this.selectedVariants,
    required this.onVariantToggled,
    required this.onQuantityChanged,
  });

  final List<Variant> variants;
  final Map<int, int> selectedVariants; // variant index -> quantity
  final ValueChanged<int> onVariantToggled;
  final ValueChanged<(int, int)> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Select Variants',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: List<Widget>.generate(variants.length, (int index) {
            final Variant variant = variants[index];
            final bool isSelected = selectedVariants.containsKey(index);
            final int quantity = selectedVariants[index] ?? 0;

            String label = '';
            if (variant.configurators.isNotEmpty) {
              label = variant.configurators.map((c) => c.value).join(' / ');
            } else {
              label = 'Option ${index + 1}';
            }

            final bool isInStock = variant.quantity > 0;
            final String? priceText =
                variant.pricing?.formattedCurrentPrice.isNotEmpty == true
                    ? variant.pricing!.formattedCurrentPrice
                    : null;

            return GestureDetector(
              onTap: isInStock ? () => onVariantToggled(index) : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(minWidth: 120),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: isInStock
                          ? Colors.white
                          : scheme.surfaceContainerHighest,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isInStock
                                ? const Color(0xFFD6CBBF)
                                : scheme.outline,
                        width: isSelected ? 2.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          label,
                          style: TextStyle(
                            color: isInStock
                                ? AppColors.navy
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (priceText != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            priceText,
                            style: TextStyle(
                              color: isInStock
                                  ? AppColors.pink
                                  : scheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (!isInStock) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (isSelected && quantity > 1) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Qty $quantity',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        if (selectedVariants.isNotEmpty) ...[
          const SizedBox(height: Spacing.md),
          ...selectedVariants.entries.map((MapEntry<int, int> entry) {
            final int variantIndex = entry.key;
            final int quantity = entry.value;
            final Variant variant = variants[variantIndex];

            String label = '';
            if (variant.configurators.isNotEmpty) {
              label = variant.configurators.map((c) => c.value).join(' / ');
            } else {
              label = 'Option ${variantIndex + 1}';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: quantity > 1
                              ? () => onQuantityChanged(
                                    (variantIndex, quantity - 1),
                                  )
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        Container(
                          width: 36,
                          alignment: Alignment.center,
                          child: Text(
                            '$quantity',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: variant.quantity > quantity
                              ? () => onQuantityChanged(
                                    (variantIndex, quantity + 1),
                                  )
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
