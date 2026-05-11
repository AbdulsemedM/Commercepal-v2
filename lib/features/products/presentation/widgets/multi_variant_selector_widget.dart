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
  final ValueChanged<int> onVariantToggled; // Toggle variant selection
  final ValueChanged<(int, int)> onQuantityChanged; // (variant index, new quantity)

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Variants',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: List.generate(
              variants.length,
              (index) {
                final variant = variants[index];
                final isSelected = selectedVariants.containsKey(index);
                final quantity = selectedVariants[index] ?? 0;
                
                // Get variant label from configurators
                String label = '';
                if (variant.configurators.isNotEmpty) {
                  label = variant.configurators
                      .map((c) => c.value)
                      .join(' / ');
                } else {
                  label = 'Option ${index + 1}';
                }

                // Check if variant is in stock
                final isInStock = variant.quantity > 0;

                return GestureDetector(
                  onTap: isInStock
                      ? () => onVariantToggled(index)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isInStock
                              ? scheme.surface
                              : scheme.surfaceContainerHighest,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isInStock
                                ? scheme.outlineVariant
                                : scheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isInStock
                                        ? scheme.onSurface
                                        : scheme.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            if (isSelected && quantity > 0) ...[
                              const SizedBox(width: Spacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$quantity',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (variant.pricing != null &&
                            variant.pricing!.formattedCurrentPrice.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            variant.pricing!.formattedCurrentPrice,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Quantity controls for selected variants
          if (selectedVariants.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            ...selectedVariants.entries.map((entry) {
              final variantIndex = entry.key;
              final quantity = entry.value;
              final variant = variants[variantIndex];
              
              String label = '';
              if (variant.configurators.isNotEmpty) {
                label = variant.configurators
                    .map((c) => c.value)
                    .join(' / ');
              } else {
                label = 'Option ${variantIndex + 1}';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: Spacing.sm),
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: scheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: quantity > 1
                                ? () => onQuantityChanged((variantIndex, quantity - 1))
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
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: variant.quantity > quantity
                                ? () => onQuantityChanged((variantIndex, quantity + 1))
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
      ),
    );
  }
}
