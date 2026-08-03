import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';

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
    if (widget.specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<MapEntry<String, String>> entries =
        widget.specifications.entries.toList();
    final bool canExpand = entries.length > widget.collapsedCount;
    final List<MapEntry<String, String>> visible = _expanded || !canExpand
        ? entries
        : entries.take(widget.collapsedCount).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.md),
        decoration: AppDecorations.elevatedCard(background: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Specifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
            ),
            const SizedBox(height: Spacing.sm),
            ...List<Widget>.generate(visible.length, (int index) {
              final MapEntry<String, String> entry = visible[index];
              return Column(
                children: <Widget>[
                  if (index > 0)
                    Divider(height: 1, color: Colors.grey[200]),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Text(
                            entry.key,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          flex: 6,
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.right,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            if (canExpand) ...[
              const SizedBox(height: Spacing.xs),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.pink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                  ),
                  child: Text(
                    _expanded
                        ? 'Show less'
                        : 'Show all ${entries.length} specifications',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
