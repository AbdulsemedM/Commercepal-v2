import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../services/localization_service.dart';

/// Full-screen error when checkout returns without a valid [paymentInitiation]
/// and there is no [paymentReference] to send the user to retry payment.
class CheckoutInitiationFailedScreen extends StatelessWidget {
  const CheckoutInitiationFailedScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: Text(
          LocalizationService.t(context, 'checkout.paymentCouldNotStartTitle'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: Spacing.xl),
              Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: Spacing.lg),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  LocalizationService.t(context, 'checkout.tryAgain'),
                ),
              ),
              const SizedBox(height: Spacing.md),
              OutlinedButton(
                onPressed: () =>
                    context.go('${AppRoutes.dashboard}?tab=2'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  LocalizationService.t(context, 'checkout.backToCart'),
                ),
              ),
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
