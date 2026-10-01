import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/widgets/checkout_step_indicator.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/app_analytics.dart';
import '../../../../app/router/app_router.dart';
import '../../../cart/data/models/cart.dart';
import '../../../addresses/data/models/address.dart';
import '../../../addresses/bloc/address_bloc.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/address_selection_section.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  const CheckoutSummaryScreen({super.key});

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  Address? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    final cart = GoRouterState.of(context).extra as Cart?;

    if (cart == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              CheckoutScreenHeader(
                title: LocalizationService.t(context, 'checkout.checkout'),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    LocalizationService.t(context, 'checkout.cartDataNotFound'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => AddressBloc()..add(AddressLoadRequested()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CheckoutScreenHeader(
                title: LocalizationService.t(context, 'checkout.checkout'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutStepIndicator(
                        currentStep: 1,
                        totalSteps: 3,
                        labels: <String>[
                          LocalizationService.t(context, 'checkout.stepCart'),
                          LocalizationService.t(
                            context,
                            'checkout.stepPayment',
                          ),
                          LocalizationService.t(
                            context,
                            'checkout.stepConfirm',
                          ),
                        ],
                      ),
                      AddressSelectionSection(
                        onAddressSelected: (address) {
                          setState(() {
                            _selectedAddress = address;
                          });
                        },
                      ),
                      const SizedBox(height: Spacing.lg),
                      OrderSummaryCard(cart: cart),
                      const SizedBox(height: Spacing.xl),
                    ],
                  ),
                ),
              ),
              _ContinueBar(
                total: cart.estimatedTotal,
                currency: cart.currency,
                enabled: _selectedAddress != null,
                onContinue: () {
                  AppAnalytics.logBeginCheckout(
                    value: cart.estimatedTotal,
                    currency: cart.currency,
                  );
                  context.push(
                    AppRoutes.paymentSelection,
                    extra: <String, dynamic>{
                      'cart': cart,
                      'address': _selectedAddress,
                      'phoneNumber': _selectedAddress!.phoneNumber,
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({
    required this.total,
    required this.currency,
    required this.enabled,
    required this.onContinue,
  });

  final double total;
  final String currency;
  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: context.commerce.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.sm,
            Spacing.gutter,
            Spacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.tr('checkout.total'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  PriceTag(
                    amount: total,
                    currency:
                        CountryCurrencyConstants.getCurrencySymbol(currency),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              AppButton.primary(
                label: context.tr('checkout.continueToPayment'),
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: enabled ? onContinue : null,
              ),
              if (!enabled)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: Text(
                    context.tr('checkout.addAddressToContinue'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
