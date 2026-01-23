import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import '../../data/models/variant.dart';

class VariantSelectorWidget extends StatelessWidget {
  const VariantSelectorWidget({
    super.key,
    required this.variants,
    required this.selectedIndex,
    required this.onVariantSelected,
  });

  final List<Variant> variants;
  final int selectedIndex;
  final ValueChanged<int> onVariantSelected;

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Variant',
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
                final isSelected = index == selectedIndex;
                
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
                      ? () => onVariantSelected(index)
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
                              ? Colors.white
                              : Colors.grey[200],
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isInStock
                                ? Colors.grey[300]!
                                : Colors.grey[400]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isInStock
                                    ? Colors.black87
                                    : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
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
                              color: Colors.grey[600],
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
        ],
      ),
    );
  }
}
