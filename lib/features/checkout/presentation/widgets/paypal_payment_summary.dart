import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String currency = cartCurrency.toUpperCase();
    final bool isUsdCart = currency == 'USD';

    return Container(
      margin: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (errorMessage != null && errorMessage!.isNotEmpty)
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            )
          else if (isUsdCart) ...[
            _AmountRow(
              label: LocalizationService.t(context, 'checkout.paypalTotalUsd'),
              value: MoneyFormatter.format(orderTotal, 'USD'),
              emphasize: true,
            ),
          ] else ...[
            _AmountRow(
              label: LocalizationService.t(context, 'checkout.paypalTotalInCurrency')
                  .replaceAll('{currency}', currency),
              value: MoneyFormatter.format(orderTotal, currency),
            ),
            const SizedBox(height: Spacing.sm),
            _AmountRow(
              label: LocalizationService.t(context, 'checkout.paypalTotalUsd'),
              value: MoneyFormatter.format(
                exchangeRates?.toUsd(orderTotal, currency) ?? 0,
                'USD',
              ),
              emphasize: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: emphasize ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: emphasize ? AppColors.primary : AppColors.navy,
              ),
        ),
      ],
    );
  }
}
