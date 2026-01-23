import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import '../../../../app/router/app_router.dart';
import '../../../cart/data/models/cart.dart';
import '../../data/models/checkout_request.dart';
import '../../data/models/payment_method_variant.dart';
import '../../data/repository/checkout_repository.dart';
import '../../data/repository/payment_methods_repository.dart';
import '../widgets/payment_method_card.dart';

/// Helper class to represent a selectable payment method
class _SelectablePaymentMethod {
  final String id;
  final String displayName;
  final String? iconUrl;
  final String providerCode;
  final String variantCode;
  final String currency;
  final bool hasVariants;
  final List<PaymentMethodVariant> variants;

  _SelectablePaymentMethod({
    required this.id,
    required this.displayName,
    this.iconUrl,
    required this.providerCode,
    required this.variantCode,
    required this.currency,
    required this.hasVariants,
    this.variants = const [],
  });
}

/// Helper class to represent a payment method category
class _PaymentMethodCategory {
  final String categoryName;
  final String categoryCode;
  final String categoryIconUrl;
  final List<_SelectablePaymentMethod> methods;

  _PaymentMethodCategory({
    required this.categoryName,
    required this.categoryCode,
    required this.categoryIconUrl,
    required this.methods,
  });
}

class PaymentSelectionScreen extends StatefulWidget {
  const PaymentSelectionScreen({super.key});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String? _selectedPaymentMethodId;
  String? _selectedVariantCode; // Store selected variant code separately
  bool _isPlacingOrder = false;
  bool _isLoadingPaymentMethods = true;
  String? _errorMessage;
  final CheckoutRepository _checkoutRepository = CheckoutRepository();
  final PaymentMethodsRepository _paymentMethodsRepository =
      PaymentMethodsRepository();
  List<_PaymentMethodCategory> _paymentMethodCategories = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoadingPaymentMethods = true;
      _errorMessage = null;
    });

    try {
      final response = await _paymentMethodsRepository.getPaymentMethods();

      // Build payment methods structure grouped by categories
      final List<_PaymentMethodCategory> categories = [];

      for (final paymentMethod in response.data) {
        final List<_SelectablePaymentMethod> categoryMethods = [];

        for (final item in paymentMethod.paymentMethodItemResponses) {
          if (item.hasVariants) {
            // If item has variants, show only the parent item
            categoryMethods.add(
              _SelectablePaymentMethod(
                id: item.itemCode,
                displayName: item.displayName,
                iconUrl: item.iconUrl,
                providerCode: paymentMethod.code,
                variantCode:
                    item.itemCode, // Will be updated when variant is selected
                currency: item.currency,
                hasVariants: true,
                variants: item.paymentMethodItemResponses,
              ),
            );
          } else {
            // If no variants, use the item itself
            categoryMethods.add(
              _SelectablePaymentMethod(
                id: item.itemCode,
                displayName: item.displayName,
                iconUrl: item.iconUrl,
                providerCode: paymentMethod.code,
                variantCode: item.itemCode,
                currency: item.currency,
                hasVariants: false,
              ),
            );
          }
        }

        if (categoryMethods.isNotEmpty) {
          categories.add(
            _PaymentMethodCategory(
              categoryName: paymentMethod.displayName,
              categoryCode: paymentMethod.code,
              categoryIconUrl: paymentMethod.iconUrl,
              methods: categoryMethods,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _paymentMethodCategories = categories;
          _isLoadingPaymentMethods = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPaymentMethods = false;
          _errorMessage = 'Failed to load payment methods. Please try again.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showVariantSelectionDialog(
    BuildContext context,
    _SelectablePaymentMethod method,
  ) async {
    final selectedVariant = await showDialog<PaymentMethodVariant>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(method.displayName),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: method.variants.length,
            itemBuilder: (context, index) {
              final variant = method.variants[index];
              return ListTile(
                leading: variant.iconUrl.isNotEmpty
                    ? Image.network(
                        variant.iconUrl,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.payment, size: 40);
                        },
                      )
                    : Icon(Icons.payment, size: 40),
                title: Text(variant.displayName),
                onTap: () {
                  Navigator.of(context).pop(variant);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedVariant != null && mounted) {
      setState(() {
        _selectedPaymentMethodId = method.id;
        _selectedVariantCode = selectedVariant.variantCode;
      });
    }
  }

  Future<void> _placeOrder(
    Cart cart,
    int addressId,
    String? phoneNumber,
  ) async {
    if (_selectedPaymentMethodId == null) return;

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Find the selected method from categories
      _SelectablePaymentMethod? selectedMethod;
      for (final category in _paymentMethodCategories) {
        try {
          selectedMethod = category.methods.firstWhere(
            (method) => method.id == _selectedPaymentMethodId,
          );
          break;
        } catch (e) {
          // Continue searching in next category
        }
      }

      if (selectedMethod == null) {
        throw Exception('Selected payment method not found');
      }

      // Use selected variant code if available, otherwise use method's variant code
      final variantCode = _selectedVariantCode ?? selectedMethod.variantCode;

      // Convert cart items to checkout items
      final checkoutItems = cart.items.map((item) {
        return CheckoutItem(
          itemId: item.productId,
          configId: item.configId,
          quantity: item.quantity,
        );
      }).toList();

      // Determine if payment account is needed (for mobile money methods)
      // Check if the provider code indicates mobile money
      final isMobileMoney =
          ['MOBILE_MONEY', 'LOAN'].contains(selectedMethod.providerCode) ||
          selectedMethod.providerCode == 'MOBILE_MONEY';

      // Create checkout request
      final checkoutRequest = CheckoutRequest(
        channel: PlatformUtils.getChannel(),
        currency: cart.currency,
        deliveryAddressId: addressId,
        items: checkoutItems,
        paymentProviderCode: selectedMethod.providerCode,
        paymentProviderVariantCode: variantCode,
        paymentAccount: isMobileMoney && phoneNumber != null
            ? phoneNumber
            : null,
      );

      // Call checkout API
      final response = await _checkoutRepository.checkout(checkoutRequest);

      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Order placed successfully!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to dashboard/home
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go(AppRoutes.dashboard);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });

        // Extract error message
        String errorMessage = 'Failed to place order. Please try again.';
        if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          errorMessage = 'Session expired. Please login again.';
        } else if (e.toString().contains('400') ||
            e.toString().contains('Bad Request')) {
          errorMessage =
              'Invalid order data. Please check your cart and try again.';
        } else if (e.toString().contains('500') ||
            e.toString().contains('Server Error')) {
          errorMessage = 'Server error. Please try again later.';
        } else if (e.toString().isNotEmpty) {
          // Try to extract meaningful error message
          final errorStr = e.toString();
          if (errorStr.contains('Exception:')) {
            errorMessage = errorStr.split('Exception:').last.trim();
          } else {
            errorMessage = errorStr;
          }
        }

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get cart, addressId, and phoneNumber from route extra parameter
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final cart = extra?['cart'] as Cart?;
    final addressId = extra?['addressId'] as int?;
    final phoneNumber = extra?['phoneNumber'] as String?;

    if (cart == null || addressId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: const Center(child: Text('Missing checkout data')),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.md,
                    Spacing.md,
                    Spacing.sm,
                  ),
                  child: Text(
                    'Choose your preferred payment method',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ),
                Expanded(
                  child: _isLoadingPaymentMethods
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: Spacing.md),
                              ElevatedButton(
                                onPressed: _loadPaymentMethods,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _paymentMethodCategories.isEmpty
                      ? const Center(
                          child: Text('No payment methods available'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(Spacing.md),
                          itemCount: _paymentMethodCategories.length,
                          itemBuilder: (context, categoryIndex) {
                            final category = _paymentMethodCategories[categoryIndex];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category header
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: Spacing.sm,
                                    top: categoryIndex > 0 ? Spacing.md : 0,
                                  ),
                                  child: Row(
                                    children: [
                                      if (category.categoryIconUrl.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(right: Spacing.sm),
                                          child: Image.network(
                                            category.categoryIconUrl,
                                            width: 24,
                                            height: 24,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                      Text(
                                        category.categoryName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Payment methods grid for this category
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: Spacing.sm,
                                        mainAxisSpacing: Spacing.sm,
                                        childAspectRatio: 1.0,
                                      ),
                                  itemCount: category.methods.length,
                                  itemBuilder: (context, index) {
                                    final method = category.methods[index];
                                    return PaymentMethodCard(
                                      paymentMethodId: method.id,
                                      paymentMethodName: method.displayName,
                                      iconUrl: method.iconUrl,
                                      description: method.currency,
                                      isSelected: _selectedPaymentMethodId == method.id,
                                      onTap: () {
                                        if (method.hasVariants) {
                                          _showVariantSelectionDialog(context, method);
                                        } else {
                                          setState(() {
                                            _selectedPaymentMethodId = method.id;
                                            _selectedVariantCode = null;
                                          });
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
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
                  onPressed:
                      (_selectedPaymentMethodId == null || _isPlacingOrder)
                      ? null
                      : () {
                          _placeOrder(cart, addressId, phoneNumber);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
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
