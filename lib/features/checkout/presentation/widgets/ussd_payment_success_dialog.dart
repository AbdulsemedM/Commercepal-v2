import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter/material.dart';

/// Popup shown after successful checkout for USSD-style payments
/// (Telebirr, eBirr Coopay/Kaffi, Sahay Pay, Pesapal).
class UssdPaymentSuccessDialog extends StatelessWidget {
  const UssdPaymentSuccessDialog({
    super.key,
    this.orderNumber,
  });

  final String? orderNumber;

  /// Shows the dialog and returns when the user taps Continue.
  static Future<void> show(
    BuildContext context, {
    String? orderNumber,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UssdPaymentSuccessDialog(orderNumber: orderNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    final bool hasOrderNumber = orderNumber != null && orderNumber!.isNotEmpty;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: ExcludeSemantics(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: commerce.successContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone_iphone_rounded,
                      size: 36,
                      color: commerce.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Semantics(
                header: true,
                child: Text(
                  context.tr('checkout.ussdSuccessTitle'),
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                context.tr('checkout.ussdSuccessMessage'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.md),
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: commerce.successContainer,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_rounded,
                        size: AppSizes.iconMd,
                        color: commerce.onSuccessContainer,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          context.tr('checkout.ussdSuccessOrderPlaced'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: commerce.onSuccessContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasOrderNumber) ...<Widget>[
                const SizedBox(height: Spacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          context.tr('checkout.orderPlaced.orderNumber'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Flexible(
                        flex: 2,
                        child: SelectableText(
                          orderNumber!,
                          textAlign: TextAlign.end,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: Spacing.xl),
              AppButton.primary(
                label: context.tr('checkout.ussdSuccessContinue'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
