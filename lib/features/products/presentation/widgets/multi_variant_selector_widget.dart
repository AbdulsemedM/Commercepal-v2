import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../data/models/variant.dart';

/// Multi-select option tiles; each selected option gets its own quantity.
class MultiVariantSelectorWidget extends StatelessWidget {
  const MultiVariantSelectorWidget({
    super.key,
    required this.variants,
    required this.selectedVariants,
    required this.onVariantToggled,
    required this.onQuantityChanged,
  });

  final List<Variant> variants;

  /// variant index -> quantity
  final Map<int, int> selectedVariants;
  final ValueChanged<int> onVariantToggled;
  final ValueChanged<(int, int)> onQuantityChanged;

  String _label(BuildContext context, int index) {
    final Variant v = variants[index];
    if (v.configurators.isNotEmpty) {
      return v.configurators.map((c) => c.value).join(' / ');
    }
    return context.tr('product.option', <String, Object?>{'n': index + 1});
  }

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.tr('product.chooseOptions'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: List<Widget>.generate(variants.length, (int index) {
            final Variant variant = variants[index];
            final bool selected = selectedVariants.containsKey(index);
            final bool inStock = variant.quantity > 0;
            final String? priceText =
                variant.pricing?.formattedCurrentPrice.isNotEmpty == true
                    ? variant.pricing!.formattedCurrentPrice
                    : null;
            final Color fg =
                inStock ? scheme.onSurface : scheme.onSurfaceVariant;

            return Semantics(
              button: true,
              selected: selected,
              enabled: inStock,
              child: Material(
                color: selected
                    ? scheme.primaryContainer
                    : (inStock ? scheme.surface : scheme.surfaceContainerHigh),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                  side: BorderSide(
                    color: selected ? scheme.primary : scheme.outline,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: AppRadius.mdAll,
                  onTap: inStock
                      ? () {
                          HapticFeedback.selectionClick();
                          onVariantToggled(index);
                        }
                      : null,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 96),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs + 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _label(context, index),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: fg,
                              decoration:
                                  inStock ? null : TextDecoration.lineThrough,
                            ),
                          ),
                          if (priceText != null)
                            Text(
                              priceText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (!inStock)
                            Text(
                              context.tr('product.outOfStock'),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (selectedVariants.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.md),
          Card(
            child: Column(
              children: <Widget>[
                for (final MapEntry<int, int> entry
                    in selectedVariants.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _label(context, entry.key),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        QuantityStepper(
                          compact: true,
                          value: entry.value,
                          max: variants[entry.key].quantity > 0
                              ? variants[entry.key].quantity
                              : 99,
                          onChanged: (int q) =>
                              onQuantityChanged((entry.key, q)),
                          onRemove: () => onVariantToggled(entry.key),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
