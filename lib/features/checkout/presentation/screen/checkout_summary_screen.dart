import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/widgets/checkout_step_indicator.dart';
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // Get cart from route extra parameter
    final cart = GoRouterState.of(context).extra as Cart?;

    if (cart == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(LocalizationService.t(context, 'checkout.checkout')),
          backgroundColor: scheme.surface,
          iconTheme: IconThemeData(color: scheme.onSurface),
        ),
        body: Center(child: Text(LocalizationService.t(context, 'checkout.cartDataNotFound'))),
      );
    }

    return BlocProvider(
      create: (context) => AddressBloc()..add(AddressLoadRequested()),
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: Text(
            LocalizationService.t(context, 'checkout.checkout'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: scheme.onSurface,
            ),
          ),
          backgroundColor: scheme.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: scheme.onSurface),
        ),
        body: Column(
          children: [
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
                        LocalizationService.t(context, 'checkout.stepPayment'),
                        LocalizationService.t(context, 'checkout.stepConfirm'),
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    // Order Summary
                    OrderSummaryCard(cart: cart),
                    const SizedBox(height: Spacing.sm),
                    // Address Selection
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
            // Continue Button
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selectedAddressId == null
                        ? null
                        : () {
                            AppAnalytics.logBeginCheckout(
                              value: cart.estimatedTotal,
                              currency: cart.currency,
                            );
                            // Navigate to payment selection screen
                            context.push(
                              AppRoutes.paymentSelection,
                              extra: {
                                'cart': cart,
                                'addressId': _selectedAddressId,
                                'phoneNumber': _selectedAddressPhoneNumber,
                              },
                            );
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    ),
                    child: Text(
                      LocalizationService.t(context, 'checkout.continueToPayment'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
