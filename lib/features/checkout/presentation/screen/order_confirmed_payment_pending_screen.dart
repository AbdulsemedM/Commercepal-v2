import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../services/localization_service.dart';
import '../../data/models/checkout_response.dart';

/// Shown after checkout when payment is initiated but not yet completed
/// (e.g. [CheckoutResponse.nextActionOpenAdditionalInput]).
class OrderConfirmedPaymentPendingScreen extends StatelessWidget {
  const OrderConfirmedPaymentPendingScreen({
    super.key,
    required this.response,
  });

  final CheckoutResponse response;

  static const Color _successTint = Color(0xFFE8F5E9);
  static const Color _successBorder = Color(0xFFA5D6A7);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final orderNum = response.resolvedOrderNumber ?? '';
    final summary = response.pricingSummary;
    final currency =
        (summary?.currency ?? response.currency ?? '').trim().isNotEmpty
            ? (summary?.currency ?? response.currency)!.trim()
            : 'ETB';
    final subtotal = summary?.subtotal;
    final total = summary?.totalAmount ?? subtotal;
    final instructions =
        response.paymentInitiation?.paymentInstructions?.trim() ?? '';
    final pending = (response.paymentStatus ?? '').toUpperCase() == 'PENDING';

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl,
            vertical: Spacing.lg,
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: Spacing.md),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _successTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: _successBorder, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.shield_outlined,
                      size: 44,
                      color: AppColors.success.withOpacity(0.9),
                    ),
                    Positioned(
                      bottom: 18,
                      child: Icon(
                        Icons.check_rounded,
                        size: 22,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                LocalizationService.t(context, 'checkout.orderConfirmedTitle'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                LocalizationService.t(context, 'checkout.orderConfirmedSubtitle'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              if (pending) _PaymentInitiatedBanner(theme: theme, scheme: scheme),
              if (pending) const SizedBox(height: Spacing.lg),
              _OrderSummaryCard(
                theme: theme,
                scheme: scheme,
                orderNumber: orderNum,
                subtotal: subtotal,
                total: total,
                currency: currency,
                showInitiatedBadge: pending,
              ),
              const SizedBox(height: Spacing.lg),
              _InstructionsCard(
                theme: theme,
                scheme: scheme,
                instructions: instructions,
              ),
              const SizedBox(height: Spacing.xxl),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.orderHistory),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB45309),
                        side: const BorderSide(color: AppColors.secondary),
                        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        LocalizationService.t(context, 'checkout.myOrders'),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.go(AppRoutes.dashboard),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: Text(
                        LocalizationService.t(
                          context,
                          'checkout.continueShopping',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: LocalizationService.t(
                        context,
                        'checkout.orderConfirmedHelpPrefix',
                      ),
                    ),
                    TextSpan(
                      text: orderNum,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentInitiatedBanner extends StatelessWidget {
  const _PaymentInitiatedBanner({required this.theme, required this.scheme});

  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final Color bannerBg = scheme.brightness == Brightness.dark
        ? AppColors.success.withOpacity(0.18)
        : OrderConfirmedPaymentPendingScreen._successTint;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4, right: Spacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  LocalizationService.t(
                    context,
                    'checkout.paymentInitiatedTitle',
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  LocalizationService.t(
                    context,
                    'checkout.paymentInitiatedBody',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.theme,
    required this.scheme,
    required this.orderNumber,
    required this.subtotal,
    required this.total,
    required this.currency,
    required this.showInitiatedBadge,
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final String orderNumber;
  final num? subtotal;
  final num? total;
  final String currency;
  final bool showInitiatedBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      LocalizationService.t(context, 'checkout.orderNumberLabel'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      orderNumber.isEmpty ? '—' : orderNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (showInitiatedBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.brightness == Brightness.dark
                        ? AppColors.success.withOpacity(0.2)
                        : OrderConfirmedPaymentPendingScreen._successTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        LocalizationService.t(
                          context,
                          'checkout.statusInitiated',
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Divider(height: Spacing.xl, color: scheme.outlineVariant),
          if (subtotal != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  LocalizationService.t(context, 'checkout.subtotal'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  MoneyFormatter.format(subtotal!, currency),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          if (subtotal != null) const SizedBox(height: Spacing.sm),
          Divider(height: Spacing.lg, color: scheme.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'checkout.totalDue'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                total != null
                    ? MoneyFormatter.format(total!, currency)
                    : '—',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({
    required this.theme,
    required this.scheme,
    required this.instructions,
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final String instructions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocalizationService.t(context, 'checkout.howToCompletePayment'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            instructions.isEmpty
                ? LocalizationService.t(
                    context,
                    'checkout.followPaymentProviderInstructions',
                  )
                : instructions,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
