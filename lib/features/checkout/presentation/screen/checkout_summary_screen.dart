import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/widgets/checkout_step_indicator.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/app_analytics.dart';
import '../../../../app/router/app_router.dart';
import '../../../cart/data/models/cart.dart';
import '../../../addresses/bloc/address_bloc.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/address_selection_section.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  const CheckoutSummaryScreen({super.key});

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  int? _selectedAddressId;
  String? _selectedAddressPhoneNumber;

  @override
  Widget build(BuildContext context) {
    final cart = GoRouterState.of(context).extra as Cart?;

    if (cart == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      const SizedBox(height: Spacing.sm),
                      OrderSummaryCard(cart: cart),
                      const SizedBox(height: Spacing.sm),
                      AddressSelectionSection(
                        onAddressSelected: (addressId, phoneNumber) {
                          setState(() {
                            _selectedAddressId = addressId;
                            _selectedAddressPhoneNumber = phoneNumber;
                          });
                        },
                      ),
                      const SizedBox(height: Spacing.xl),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.sm,
                    Spacing.md,
                    Spacing.md,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _selectedAddressId == null
                          ? null
                          : AppDecorations.primaryCtaGradient,
                      color: _selectedAddressId == null
                          ? Colors.grey.shade300
                          : null,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _selectedAddressId == null
                          ? null
                          : <BoxShadow>[
                              BoxShadow(
                                color: AppColors.pink.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _selectedAddressId == null
                            ? null
                            : () {
                                AppAnalytics.logBeginCheckout(
                                  value: cart.estimatedTotal,
                                  currency: cart.currency,
                                );
                                context.push(
                                  AppRoutes.paymentSelection,
                                  extra: {
                                    'cart': cart,
                                    'addressId': _selectedAddressId,
                                    'phoneNumber':
                                        _selectedAddressPhoneNumber,
                                  },
                                );
                              },
                        borderRadius: BorderRadius.circular(28),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.md + 2,
                          ),
                          child: Center(
                            child: Text(
                              LocalizationService.t(
                                context,
                                'checkout.continueToPayment',
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _selectedAddressId == null
                                    ? Colors.grey.shade600
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
