import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

/// Beautiful popup shown after successful checkout for USSD-style payments
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
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              LocalizationService.t(context, 'checkout.ussdSuccessTitle'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              LocalizationService.t(context, 'checkout.ussdSuccessMessage'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              LocalizationService.t(context, 'checkout.ussdSuccessOrderPlaced'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (orderNumber != null && orderNumber!.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  orderNumber!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: Spacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  LocalizationService.t(context, 'checkout.ussdSuccessContinue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
