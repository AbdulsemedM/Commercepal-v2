import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
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
  String? _cartCurrency; // Cart currency for filtering payment methods (e.g. ETB, USD)
  final CheckoutRepository _checkoutRepository = CheckoutRepository();
  final PaymentMethodsRepository _paymentMethodsRepository =
      PaymentMethodsRepository();
  List<_PaymentMethodCategory> _paymentMethodCategories = [];
  bool _paymentMethodsLoadStarted = false;
  final TextEditingController _paymentPhoneController =
      TextEditingController(text: '9');
  String? _paymentPhoneNumber;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _paymentPhoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read cart currency from route extra here (not in initState) because
    // GoRouterState.of(context) uses inherited widgets.
    if (_cartCurrency == null) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        final cart = extra['cart'];
        if (cart is Cart) {
          _cartCurrency = cart.currency;
        }
      }
    }
    if (!_paymentMethodsLoadStarted) {
      _paymentMethodsLoadStarted = true;
      _loadPaymentMethods();
    }
  }

  bool _currencyMatches(String? methodCurrency) {
    if (_cartCurrency == null || methodCurrency == null) return true;
    return _cartCurrency!.toUpperCase() == methodCurrency.toUpperCase();
  }

  _SelectablePaymentMethod? _getSelectedMethod() {
    if (_selectedPaymentMethodId == null) return null;
    for (final category in _paymentMethodCategories) {
      try {
        return category.methods.firstWhere(
          (m) => m.id == _selectedPaymentMethodId,
        );
      } catch (_) {}
    }
    return null;
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoadingPaymentMethods = true;
      _errorMessage = null;
    });

    try {
      final response = await _paymentMethodsRepository.getPaymentMethods();

      // Build payment methods structure grouped by categories, filtered by cart currency
      final List<_PaymentMethodCategory> categories = [];

      for (final paymentMethod in response.data) {
        final List<_SelectablePaymentMethod> categoryMethods = [];

        for (final item in paymentMethod.paymentMethodItemResponses) {
          if (item.hasVariants) {
            // Filter variants by cart currency; only show method if at least one variant matches
            final matchingVariants = item.paymentMethodItemResponses
                .where((v) => _currencyMatches(v.currency))
                .toList();
            if (matchingVariants.isEmpty) continue;
            categoryMethods.add(
              _SelectablePaymentMethod(
                id: item.itemCode,
                displayName: item.displayName,
                iconUrl: item.iconUrl,
                providerCode: paymentMethod.code,
                variantCode: item.itemCode,
                currency: item.currency,
                hasVariants: true,
                variants: matchingVariants,
              ),
            );
          } else {
            // No variants: only show if method currency matches cart currency
            if (!_currencyMatches(item.currency)) continue;
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

      // paymentProviderCode = payment item code (itemCode)
      // paymentProviderVariantCode = variant code only when the payment has a variant
      final paymentItemCode = selectedMethod.id; // id is item.itemCode (payment item code)
      final variantCode = selectedMethod.hasVariants && _selectedVariantCode != null
          ? _selectedVariantCode!
          : '';

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
        paymentProviderCode: paymentItemCode,
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

        // Show order placed screen with backend response data and payment
        // codes (for retry payment if needed)
        if (context.mounted) {
          context.go(
            AppRoutes.orderPlaced,
            extra: <String, dynamic>{
              'checkoutResponse': response,
              'paymentProviderCode': paymentItemCode,
              'paymentProviderVariantCode': variantCode,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });

        // Extract error message, preferring API response body when available
        String errorMessage = 'Failed to place order. Please try again.';
        if (e is DioException && e.response?.data is Map<String, dynamic>) {
          final data = e.response!.data! as Map<String, dynamic>;
          final apiMessage = data['message'] as String?;
          if (apiMessage != null && apiMessage.isNotEmpty) {
            errorMessage = apiMessage;
          }
        }
        if (errorMessage == 'Failed to place order. Please try again.') {
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
            final errorStr = e.toString();
            if (errorStr.contains('Exception:')) {
              errorMessage = errorStr.split('Exception:').last.trim();
            } else {
              errorMessage = errorStr;
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
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

    final selectedMethod = _getSelectedMethod();
    final requiresPhone = selectedMethod != null &&
        ['MOBILE_MONEY', 'LOAN'].contains(selectedMethod.providerCode);
    final isETB = cart.currency.toUpperCase() == 'ETB';
    final showPhoneField = requiresPhone && isETB;
    final effectivePhone = showPhoneField
        ? (_paymentPhoneNumber ?? phoneNumber)
        : phoneNumber;

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
          // Phone number for payment (ETB mobile money only)
          if (showPhoneField)
            Container(
              padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, Spacing.md),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mobile number for payment',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  IntlPhoneField(
                    controller: _paymentPhoneController,
                    initialCountryCode: 'ET',
                    flagsButtonPadding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                    ),
                    dropdownIconPosition: IconPosition.trailing,
                    decoration: InputDecoration(
                      hintText: '912345678',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.md,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    onChanged: (phone) {
                      setState(() {
                        _paymentPhoneNumber = phone.completeNumber.isNotEmpty
                            ? phone.completeNumber
                            : null;
                      });
                    },
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
                  onPressed: (_selectedPaymentMethodId == null ||
                          _isPlacingOrder ||
                          (showPhoneField &&
                              (effectivePhone == null ||
                                  effectivePhone.isEmpty)))
                      ? null
                      : () {
                          _placeOrder(cart, addressId, effectivePhone);
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
