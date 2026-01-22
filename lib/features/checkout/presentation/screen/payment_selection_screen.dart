import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import '../../../cart/data/models/cart.dart';
import '../widgets/payment_method_card.dart';

class PaymentSelectionScreen extends StatefulWidget {
  const PaymentSelectionScreen({super.key});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String? _selectedPaymentMethodId;

  // Placeholder payment methods - will be replaced with API data
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
    },
    {
      'id': 'mobile_money',
      'name': 'Mobile Money',
      'icon': Icons.phone_android,
    },
    {
      'id': 'cash_on_delivery',
      'name': 'Cash on Delivery',
      'icon': Icons.money,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get cart and addressId from route extra parameter
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final cart = extra?['cart'] as Cart?;
    final addressId = extra?['addressId'] as int?;

    if (cart == null || addressId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: const Center(
          child: Text('Missing checkout data'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Select Payment Method',
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
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    ),
                    child: Text(
                      'Choose your preferred payment method',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  // Payment method cards
                  ..._paymentMethods.map((method) => PaymentMethodCard(
                        paymentMethodId: method['id'] as String,
                        paymentMethodName: method['name'] as String,
                        icon: method['icon'] as IconData,
                        isSelected: _selectedPaymentMethodId == method['id'],
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethodId = method['id'] as String;
                          });
                        },
                      )),
                  const SizedBox(height: Spacing.xl),
                ],
              ),
            ),
          ),
          // Place Order Button
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
                  onPressed: _selectedPaymentMethodId == null
                      ? null
                      : () {
                          // TODO: Implement order placement API call
                          // For now, show a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Order placement functionality will be implemented with API',
                              ),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          // Navigate back to dashboard/home after order placement
                          // context.go(AppRoutes.dashboard);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.md,
                    ),
                  ),
                  child: const Text(
                    'Place Order',
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
    );
  }
}
