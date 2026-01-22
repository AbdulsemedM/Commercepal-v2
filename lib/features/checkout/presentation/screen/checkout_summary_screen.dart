import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
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

  @override
  Widget build(BuildContext context) {
    // Get cart from route extra parameter
    final cart = GoRouterState.of(context).extra as Cart?;

    if (cart == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: const Center(child: Text('Cart data not found')),
      );
    }

    return BlocProvider(
      create: (context) => AddressBloc()..add(AddressLoadRequested()),
      child: Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          title: const Text(
            'Checkout',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    OrderSummaryCard(cart: cart),
                    const SizedBox(height: Spacing.sm),
                    // Address Selection
                    AddressSelectionSection(
                      onAddressSelected: (addressId) {
                        setState(() {
                          _selectedAddressId = addressId;
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
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
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
                            // Navigate to payment selection screen
                            context.push(
                              AppRoutes.paymentSelection,
                              extra: {
                                'cart': cart,
                                'addressId': _selectedAddressId,
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
                    child: const Text(
                      'Continue to Payment',
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
