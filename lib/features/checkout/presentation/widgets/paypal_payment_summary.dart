import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/checkout/data/models/exchange_rates_response.dart';
import 'package:commercepal/services/localization_service.dart';

/// Shows PayPal payment totals instead of the phone field.
/// Non-USD carts: local currency total + USD equivalent. USD carts: USD only.
class PayPalPaymentSummary extends StatelessWidget {
  const PayPalPaymentSummary({
    super.key,
    required this.cartCurrency,
    required this.orderTotal,
    this.exchangeRates,
    this.isLoading = false,
    this.errorMessage,
  });

  final String cartCurrency;
  final double orderTotal;
  final ExchangeRatesData? exchangeRates;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String currency = cartCurrency.toUpperCase();
    final bool isUsdCart = currency == 'USD';

    final Widget content;
    if (isLoading) {
      content = Semantics(
        label: context.tr('checkout.paypal.loadingAmounts'),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    } else if (errorMessage != null && errorMessage!.isNotEmpty) {
      content = Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              color: scheme.error,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Text(
                errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (isUsdCart) {
      content = _AmountRow(
        label: context.tr('checkout.paypalTotalUsd'),
        amount: orderTotal,
        currency: 'USD',
        emphasize: true,
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _AmountRow(
            label: context.tr(
              'checkout.paypalTotalInCurrency',
              <String, Object?>{'currency': currency},
            ),
            amount: orderTotal,
            currency: currency,
          ),
          const SizedBox(height: Spacing.xs),
          _AmountRow(
            label: context.tr('checkout.paypalTotalUsd'),
            amount: exchangeRates?.toUsd(orderTotal, currency) ?? 0,
            currency: 'USD',
            emphasize: true,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            context.tr('checkout.paypal.conversionNote'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(
        Spacing.gutter,
        Spacing.sm,
        Spacing.gutter,
        0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.fast,
          curve: AppMotion.standard,
          alignment: AlignmentDirectional.topStart,
          child: content,
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    required this.currency,
    this.emphasize = false,
  });

  final String label;
  final num amount;
  final String currency;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: emphasize
                ? theme.textTheme.titleSmall
                : theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        PriceTag(
          amount: amount,
          currency: CountryCurrencyConstants.getCurrencySymbol(currency),
          size: emphasize ? PriceTagSize.medium : PriceTagSize.small,
          color: emphasize ? null : scheme.onSurface,
        ),
      ],
    );
  }
}
