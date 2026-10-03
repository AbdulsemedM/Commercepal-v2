import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// Key/value specification table, collapsed to [collapsedCount] rows.
class ProductSpecifications extends StatefulWidget {
  const ProductSpecifications({
    super.key,
    required this.specifications,
    this.collapsedCount = 5,
  });

  final Map<String, String> specifications;
  final int collapsedCount;

  @override
  State<ProductSpecifications> createState() => _ProductSpecificationsState();
}

class _ProductSpecificationsState extends State<ProductSpecifications> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.specifications.isEmpty) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<MapEntry<String, String>> entries =
        widget.specifications.entries.toList();
    final bool canExpand = entries.length > widget.collapsedCount;
    final List<MapEntry<String, String>> visible = _expanded || !canExpand
        ? entries
        : entries.take(widget.collapsedCount).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              context.tr('product.specifications'),
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Card(
            child: AnimatedSize(
              duration: AppMotion.medium,
              alignment: Alignment.topCenter,
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < visible.length; i++)
                    Container(
                      color: i.isEven
                          ? scheme.surfaceContainerLow
                          : scheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text(
                              visible[i].key,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            flex: 6,
                            child: Text(
                              visible[i].value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (canExpand)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton.text(
                label: _expanded
                    ? context.tr('product.showLess')
                    : context.tr('product.showAllSpecs', <String, Object?>{
                        'count': entries.length,
                      }),
                trailingIcon: _expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ),
        ],
      ),
    );
  }
}
