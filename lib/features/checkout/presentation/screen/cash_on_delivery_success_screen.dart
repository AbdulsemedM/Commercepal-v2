import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_router.dart';
import '../../../../services/localization_service.dart';
import '../../data/models/checkout_response.dart';

/// Shown after a successful cash-on-delivery checkout.
class CashOnDeliverySuccessScreen extends StatelessWidget {
  const CashOnDeliverySuccessScreen({
    super.key,
    required this.response,
  });

  final CheckoutResponse response;

  static String? _formatOrderedAt(String? orderedAt) {
    if (orderedAt == null || orderedAt.isEmpty) return null;
    final dt = DateTime.tryParse(orderedAt);
    if (dt == null) return orderedAt;
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    final orderNumber = response.resolvedOrderNumber ?? '';
    final summary = response.pricingSummary;
    final currency =
        (summary?.currency ?? response.currency ?? '').trim().isNotEmpty
            ? (summary?.currency ?? response.currency)!.trim()
            : 'ETB';
    final orderedAt = _formatOrderedAt(response.orderedAt);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            CheckoutScreenHeader(
              title: context.tr('checkout.orderPlaced.confirmationTitle'),
              showBack: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  Spacing.gutter,
                  Spacing.xs,
                  Spacing.gutter,
                  Spacing.xl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: Spacing.md),
                        Center(
                          child: ExcludeSemantics(
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: commerce.successContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 44,
                                color: commerce.success,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        Semantics(
                          header: true,
                          child: Text(
                            context.tr('checkout.codSuccessTitle'),
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          context.tr('checkout.codSuccessSubtitle'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.xl),
                        const _CodInfoBanner(),
                        const SizedBox(height: Spacing.md),
                        _OrderDetailsCard(
                          orderNumber: orderNumber,
                          summary: summary,
                          currency: currency,
                          orderedAt: orderedAt,
                        ),
                        const SizedBox(height: Spacing.lg),
                        Text.rich(
                          TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: context
                                    .tr('checkout.orderConfirmedHelpPrefix'),
                              ),
                              TextSpan(
                                text: orderNumber,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: AppTypography.tabularFigures,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: commerce.border)),
              ),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        Spacing.gutter,
                        Spacing.sm,
                        Spacing.gutter,
                        Spacing.sm,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AppButton.primary(
                            label: context.tr('checkout.goToHome'),
                            icon: Icons.home_outlined,
                            onPressed: () => context.go(AppRoutes.dashboard),
                          ),
                          const SizedBox(height: Spacing.xs),
                          AppButton.secondary(
                            label: context.tr('checkout.myOrders'),
                            icon: Icons.receipt_long_outlined,
                            size: AppButtonSize.medium,
                            onPressed: () => context.go(AppRoutes.orderHistory),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodInfoBanner extends StatelessWidget {
  const _CodInfoBanner();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommerceColors commerce = context.commerce;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: commerce.infoContainer,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExcludeSemantics(
            child: Icon(
              Icons.payments_outlined,
              color: commerce.onInfoContainer,
              size: AppSizes.iconLg,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.tr('checkout.codPayOnDeliveryTitle'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: commerce.onInfoContainer,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  context.tr('checkout.codPayOnDeliveryBody'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: commerce.onInfoContainer,
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
    required this.orderNumber,
    required this.summary,
    required this.currency,
    required this.orderedAt,
  });

  final String orderNumber;
  final PricingSummary? summary;
  final String currency;
  final String? orderedAt;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
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
                        context.tr('checkout.orderPlaced.orderNumber'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Spacing.xxs),
                      SelectableText(
                        orderNumber.isEmpty ? '—' : orderNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFeatures: AppTypography.tabularFigures,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                AppBadge(
                  label: context.tr('checkout.orderPlaced.statusConfirmed'),
                  tone: AppBadgeTone.success,
                  size: AppBadgeSize.medium,
                ),
              ],
            ),
            const Divider(height: Spacing.xl),
            if (orderedAt != null) ...<Widget>[
              _detailRow(
                context,
                context.tr('checkout.orderPlaced.orderedOn'),
                orderedAt!,
              ),
              const SizedBox(height: Spacing.xs),
            ],
            _detailRow(
              context,
              context.tr('checkout.orderPlaced.paymentMethod'),
              context.tr('checkout.codPaymentMethod'),
            ),
            if (summary?.subtotal != null) ...<Widget>[
              const SizedBox(height: Spacing.xs),
              _detailRow(
                context,
                context.tr('checkout.subtotal'),
                MoneyFormatter.format(summary!.subtotal!, currency),
                tabular: true,
              ),
            ],
            if (summary?.deliveryFee != null &&
                (summary!.deliveryFee ?? 0) > 0) ...<Widget>[
              const SizedBox(height: Spacing.xs),
              _detailRow(
                context,
                context.tr('checkout.delivery'),
                MoneyFormatter.format(summary!.deliveryFee!, currency),
                tabular: true,
              ),
            ],
            if (summary?.discountAmount != null &&
                (summary!.discountAmount ?? 0) > 0) ...<Widget>[
              const SizedBox(height: Spacing.xs),
              _detailRow(
                context,
                context.tr('checkout.discount'),
                '-${MoneyFormatter.format(summary!.discountAmount!, currency)}',
                tabular: true,
                valueColor: commerce.success,
              ),
            ],
            const Divider(height: Spacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.tr('checkout.totalDue'),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (summary?.totalAmount != null)
                  PriceTag(
                    amount: summary!.totalAmount!,
                    currency:
                        CountryCurrencyConstants.getCurrencySymbol(currency),
                  )
                else
                  Text('—', style: theme.textTheme.titleSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    bool tabular = false,
    Color? valueColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Row(
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
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? scheme.onSurface,
              fontFeatures: tabular ? AppTypography.tabularFigures : null,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
