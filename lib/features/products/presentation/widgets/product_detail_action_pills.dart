import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';

/// Side-by-side pill CTAs for Company Profile and Customer Feedback.
class ProductDetailActionPills extends StatelessWidget {
  const ProductDetailActionPills({
    super.key,
    required this.onCompanyProfile,
    required this.onCustomerFeedback,
  });

  final VoidCallback onCompanyProfile;
  final VoidCallback onCustomerFeedback;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _PillButton(
              label: 'Company Profile',
              onTap: onCompanyProfile,
              borderColor: scheme.outlineVariant,
              textColor: scheme.onSurface,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: _PillButton(
              label: 'Customer Feedback',
              onTap: onCustomerFeedback,
              borderColor: scheme.outlineVariant,
              textColor: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.borderColor,
    required this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontSize: 13,
                ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet showing vendor / brand / provider details.
Future<void> showCompanyProfileSheet(
  BuildContext context, {
  required String vendorName,
  required String brandName,
  required String provider,
}) {
  final List<(String, String)> rows = <(String, String)>[
    if (vendorName.isNotEmpty) ('Vendor', vendorName),
    if (brandName.isNotEmpty) ('Brand', brandName),
    if (provider.isNotEmpty) ('Provider', provider),
  ];

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDecorations.radiusLg),
      ),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.sm,
            Spacing.lg,
            Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Company Profile',
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: Spacing.md),
              if (rows.isEmpty)
                Text(
                  'No company details available for this product.',
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(sheetContext)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                )
              else
                ...rows.map(
                  ((String, String) row) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 88,
                          child: Text(
                            row.$1,
                            style: Theme.of(sheetContext)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(sheetContext)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            row.$2,
                            style: Theme.of(sheetContext)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
