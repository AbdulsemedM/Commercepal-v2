import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../services/localization_service.dart';
import '../../data/models/checkout_response.dart';

/// Shown after a successful cash-on-delivery checkout.
class CashOnDeliverySuccessScreen extends StatelessWidget {
  const CashOnDeliverySuccessScreen({
    super.key,
    required this.response,
  });

  final CheckoutResponse response;

  static const Color _successTint = Color(0xFFE8F5E9);
  static const Color _successBorder = Color(0xFFA5D6A7);

  static String? _formatOrderedAt(String? orderedAt) {
    if (orderedAt == null || orderedAt.isEmpty) return null;
    final dt = DateTime.tryParse(orderedAt);
    if (dt == null) return orderedAt;
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final orderNumber = response.resolvedOrderNumber ?? '';
    final summary = response.pricingSummary;
    final currency =
        (summary?.currency ?? response.currency ?? '').trim().isNotEmpty
            ? (summary?.currency ?? response.currency)!.trim()
            : 'ETB';
    final orderedAt = _formatOrderedAt(response.orderedAt);

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
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: _successTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: _successBorder, width: 2),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.success.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                LocalizationService.t(context, 'checkout.codSuccessTitle'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                LocalizationService.t(context, 'checkout.codSuccessSubtitle'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              _CodInfoBanner(theme: theme, scheme: scheme),
              const SizedBox(height: Spacing.lg),
              _OrderDetailsCard(
                theme: theme,
                scheme: scheme,
                orderNumber: orderNumber,
                summary: summary,
                currency: currency,
                orderedAt: orderedAt,
              ),
              const SizedBox(height: Spacing.xxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  icon: const Icon(Icons.home_outlined, size: 20),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    LocalizationService.t(context, 'checkout.goToHome'),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.orderHistory),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
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
                      text: orderNumber,
                      style: const TextStyle(
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

class _CodInfoBanner extends StatelessWidget {
  const _CodInfoBanner({required this.theme, required this.scheme});

  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.brightness == Brightness.dark
            ? AppColors.success.withValues(alpha: 0.18)
            : CashOnDeliverySuccessScreen._successTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CashOnDeliverySuccessScreen._successBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.success,
            size: 22,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  LocalizationService.t(
                    context,
                    'checkout.codPayOnDeliveryTitle',
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
                    'checkout.codPayOnDeliveryBody',
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

class _OrderDetailsCard extends StatelessWidget {
  const _OrderDetailsCard({
    required this.theme,
    required this.scheme,
    required this.orderNumber,
    required this.summary,
    required this.currency,
    required this.orderedAt,
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final String orderNumber;
  final PricingSummary? summary;
  final String currency;
  final String? orderedAt;

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
          if (orderedAt != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              orderedAt!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const Divider(height: Spacing.xl),
          _detailRow(
            context,
            LocalizationService.t(context, 'checkout.payment'),
            LocalizationService.t(context, 'checkout.codPaymentMethod'),
          ),
          if (summary?.subtotal != null) ...[
            const SizedBox(height: Spacing.sm),
            _detailRow(
              context,
              LocalizationService.t(context, 'checkout.subtotal'),
              MoneyFormatter.format(summary!.subtotal!, currency),
            ),
          ],
          if (summary?.deliveryFee != null &&
              (summary!.deliveryFee ?? 0) > 0) ...[
            const SizedBox(height: Spacing.sm),
            _detailRow(
              context,
              LocalizationService.t(context, 'checkout.delivery'),
              MoneyFormatter.format(summary!.deliveryFee!, currency),
            ),
          ],
          if (summary?.discountAmount != null &&
              (summary!.discountAmount ?? 0) > 0) ...[
            const SizedBox(height: Spacing.sm),
            _detailRow(
              context,
              LocalizationService.t(context, 'checkout.discount'),
              '-${MoneyFormatter.format(summary!.discountAmount!, currency)}',
            ),
          ],
          const Divider(height: Spacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'checkout.totalDue'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                summary?.totalAmount != null
                    ? MoneyFormatter.format(summary!.totalAmount!, currency)
                    : '—',
                style: theme.textTheme.titleSmall?.copyWith(
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

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
