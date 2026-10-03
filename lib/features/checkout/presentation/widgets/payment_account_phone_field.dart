import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// Phone field shown at checkout/retry for paymentAccount entry.
///
/// Relies on the global [InputDecorationTheme] for fill, radius and the
/// focus ring so it matches every other input in the app.
class PaymentAccountPhoneField extends StatelessWidget {
  const PaymentAccountPhoneField({
    super.key,
    required this.controller,
    required this.initialCountryCode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String initialCountryCode;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(
        Spacing.gutter,
        Spacing.sm,
        Spacing.gutter,
        0,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Spacing.md,
          Spacing.sm,
          Spacing.md,
          Spacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.phone_android_rounded,
                  size: AppSizes.iconMd,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      context.tr('checkout.mobileNumberForPayment'),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              context.tr('checkout.enterNumberLinkedToAccount'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            // Phone numbers are always written left-to-right, even in Arabic.
            Directionality(
              textDirection: TextDirection.ltr,
              child: IntlPhoneField(
                controller: controller,
                initialCountryCode: initialCountryCode,
                flagsButtonPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                ),
                dropdownIconPosition: IconPosition.trailing,
                decoration: const InputDecoration(hintText: '912345678'),
                style: theme.textTheme.bodyLarge,
                onChanged: (phone) {
                  onChanged(
                    phone.completeNumber.isNotEmpty
                        ? phone.completeNumber
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
