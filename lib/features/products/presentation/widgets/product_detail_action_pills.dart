import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// "About the seller" and "Customer reviews" navigation rows.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(context.tr('product.aboutSeller')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: onCompanyProfile,
            ),
            const Divider(indent: Spacing.md, endIndent: Spacing.md),
            ListTile(
              leading: const Icon(Icons.reviews_outlined),
              title: Text(context.tr('product.customerReviews')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: onCustomerFeedback,
            ),
          ],
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
    if (vendorName.isNotEmpty) (context.tr('product.vendor'), vendorName),
    if (brandName.isNotEmpty) (context.tr('product.brand'), brandName),
    if (provider.isNotEmpty) (context.tr('product.provider'), provider),
  ];

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      final ThemeData theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            0,
            Spacing.lg,
            Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                sheetContext.tr('product.aboutSeller'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: Spacing.md),
              if (rows.isEmpty)
                Text(
                  sheetContext.tr('product.noSellerDetails'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                for (final (String label, String value) in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 96,
                          child: Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            value,
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
      );
    },
  );
}
