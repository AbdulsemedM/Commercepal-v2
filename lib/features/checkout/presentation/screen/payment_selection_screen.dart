import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../../../app/router/app_router.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/data/models/cart.dart';
import '../../data/models/checkout_request.dart';
import '../../data/models/payment_method_type.dart';
import '../../data/models/payment_method_variant.dart';
import '../../data/models/payment_constants.dart';
import '../../data/repository/checkout_repository.dart';
import '../../data/repository/payment_methods_repository.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/ussd_payment_success_dialog.dart';

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
  final String? paymentInstruction;
  final bool? requireAccountNumberOnInitiation;

  _SelectablePaymentMethod({
    required this.id,
    required this.displayName,
    this.iconUrl,
    required this.providerCode,
    required this.variantCode,
    required this.currency,
    required this.hasVariants,
    this.variants = const [],
    this.paymentInstruction,
    this.requireAccountNumberOnInitiation,
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
  final TextEditingController _methodSpecificDigitsController =
      TextEditingController();
  String? _ipayPhoneNumber;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _paymentPhoneController.dispose();
    _methodSpecificDigitsController.dispose();
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
                paymentInstruction: item.paymentInstruction,
                requireAccountNumberOnInitiation:
                    item.requireAccountNumberOnInitiation,
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
                paymentInstruction: item.paymentInstruction,
                requireAccountNumberOnInitiation:
                    item.requireAccountNumberOnInitiation,
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
          _errorMessage = LocalizationService.t(context, 'checkout.failedToLoadPaymentMethods');
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
            child: Text(LocalizationService.t(context, 'cart.cancel')),
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

  String? _getCategoryNameForSelectedMethod() {
    if (_selectedPaymentMethodId == null) return null;
    for (final category in _paymentMethodCategories) {
      final found = category.methods.any((m) => m.id == _selectedPaymentMethodId);
      if (found) return category.categoryName;
    }
    return null;
  }

  String? _getSelectedVariantDisplayName() {
    final method = _getSelectedMethod();
    if (method == null || _selectedVariantCode == null) return null;
    try {
      final v = method.variants.firstWhere(
        (e) => e.variantCode == _selectedVariantCode,
      );
      return v.displayName;
    } catch (_) {
      return null;
    }
  }

  PaymentMethodVariant? _getSelectedVariant() {
    final method = _getSelectedMethod();
    if (method == null || _selectedVariantCode == null) return null;
    try {
      return method.variants.firstWhere(
        (e) => e.variantCode == _selectedVariantCode,
      );
    } catch (_) {
      return null;
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

      // paymentProviderCode = selected option's item code (variant itemCode when has variants, else payment item's itemCode)
      final paymentProviderCode = selectedMethod.hasVariants && _selectedVariantCode != null
          ? _selectedVariantCode!
          : selectedMethod.id;

      // Sahay: customer lookup, show customer name and confirm before placing order
      if (paymentProviderCode == PaymentConstants.sahayProviderCode) {
        if (phoneNumber == null || phoneNumber.isEmpty) {
          if (mounted) {
            setState(() => _isPlacingOrder = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizationService.t(context, 'checkout.pleaseEnterValidPhone')),
                backgroundColor: AppColors.warning,
              ),
            );
          }
          return;
        }
        final lookup = await _checkoutRepository.verifySahayAccount(phoneNumber);
        if (!mounted) return;
        if (!lookup.success) {
          setState(() => _isPlacingOrder = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lookup.message ?? LocalizationService.t(context, 'checkout.phoneNumberCouldNotBeVerified'),
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        final customerName = lookup.customerName ?? lookup.accountHolderName;
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text(LocalizationService.t(ctx, 'checkout.sahayConfirmTitle')),
            content: Text(
              LocalizationService.t(ctx, 'checkout.sahayConfirmMessage')
                  .replaceAll('{name}', customerName ?? ''),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(LocalizationService.t(ctx, 'checkout.cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(LocalizationService.t(ctx, 'checkout.sahayConfirm')),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (confirmed != true) {
          setState(() => _isPlacingOrder = false);
          return;
        }
      }

      // Convert cart items to checkout items
      final checkoutItems = cart.items.map((item) {
        return CheckoutItem(
          itemId: item.productId,
          configId: item.configId,
          quantity: item.quantity,
        );
      }).toList();

      final categoryName = _getCategoryNameForSelectedMethod();
      final variantDisplayName = _getSelectedVariantDisplayName();
      final methodType = getPaymentMethodType(
        categoryName,
        selectedMethod.displayName,
        variantDisplayName,
      );

      // Determine if this payment method requires a payment account (phone number).
      // Only send paymentAccount when the method actually requires it; otherwise send null.
      final effectiveRequireAccount = _getSelectedVariant()
              ?.requireAccountNumberOnInitiation ??
          selectedMethod.requireAccountNumberOnInitiation;
      final requiresPhone = ['MOBILE_MONEY', 'LOAN']
          .contains(selectedMethod.providerCode);
      final isETB = cart.currency.toUpperCase() == 'ETB';
      final methodRequiresPaymentAccount = effectiveRequireAccount == true ||
          (effectiveRequireAccount != false &&
              ((requiresPhone && isETB) || requiresMethodSpecificPhone(methodType)));

      // Create checkout request – only include paymentAccount when method requires it
      final checkoutRequest = CheckoutRequest(
        channel: PlatformUtils.getChannel(),
        currency: cart.currency,
        deliveryAddressId: addressId,
        items: checkoutItems,
        paymentProviderCode: paymentProviderCode,
        paymentAccount: methodRequiresPaymentAccount && phoneNumber != null && phoneNumber.isNotEmpty
            ? phoneNumber
            : null,
      );

      // Call checkout API
      final response = await _checkoutRepository.checkout(checkoutRequest);

      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });

        if (!context.mounted) return;

        // Clear cart on successful order
        context.read<CartBloc>().add(CartClearRequested());

        final init = response.paymentInitiation;
        final nextAction = init?.nextAction;
        final paymentUrl = init?.paymentUrl;
        final orderNumber = response.orderNumber ?? init?.orderNumber;

        // For USSD-style payments (Telebirr, eBirr, Sahay, Pesapal): show success popup first
        if (PaymentConstants.isUssdPaymentProvider(paymentProviderCode)) {
          await UssdPaymentSuccessDialog.show(
            context,
            orderNumber: orderNumber,
          );
          if (!context.mounted) return;
        }

        // If backend says redirect to payment URL, open it in-app WebView (not browser)
        if (nextAction == 'REDIRECT_TO_PAYMENT_URL' &&
            paymentUrl != null &&
            paymentUrl.isNotEmpty) {
          context.go(
            AppRoutes.paymentWebView,
            extra: <String, dynamic>{
              'paymentUrl': paymentUrl,
              'orderNumber': orderNumber,
            },
          );
        } else {
          context.go(AppRoutes.dashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });

        // Extract error message, preferring API response body when available
        String errorMessage = LocalizationService.t(context, 'checkout.failedToPlaceOrder');
        if (e is DioException && e.response?.data is Map<String, dynamic>) {
          final data = e.response!.data! as Map<String, dynamic>;
          final apiMessage = data['message'] as String?;
          if (apiMessage != null && apiMessage.isNotEmpty) {
            errorMessage = apiMessage;
          }
        }
        if (errorMessage == LocalizationService.t(context, 'checkout.failedToPlaceOrder')) {
          if (e.toString().contains('401') ||
              e.toString().contains('Unauthorized')) {
            errorMessage = LocalizationService.t(context, 'checkout.sessionExpired');
          } else if (e.toString().contains('400') ||
              e.toString().contains('Bad Request')) {
            errorMessage = LocalizationService.t(context, 'checkout.invalidOrderData');
          } else if (e.toString().contains('500') ||
              e.toString().contains('Server Error')) {
            errorMessage = LocalizationService.t(context, 'checkout.serverError');
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
          title: Text(LocalizationService.t(context, 'checkout.payment')),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Center(child: Text(LocalizationService.t(context, 'checkout.missingCheckoutData'))),
      );
    }

    final selectedMethod = _getSelectedMethod();
    final categoryName = _getCategoryNameForSelectedMethod();
    final variantDisplayName = _getSelectedVariantDisplayName();
    final methodType = getPaymentMethodType(
      categoryName,
      selectedMethod?.displayName,
      variantDisplayName,
    );
    final waafiPrefix = getWaafiPrefix(
      categoryName,
      selectedMethod?.displayName,
      variantDisplayName,
    );

    final effectiveRequireAccount = _getSelectedVariant()
            ?.requireAccountNumberOnInitiation ??
        selectedMethod?.requireAccountNumberOnInitiation;
    final requiresPhone = selectedMethod != null &&
        ['MOBILE_MONEY', 'LOAN'].contains(selectedMethod.providerCode);
    final isETB = cart.currency.toUpperCase() == 'ETB';
    final requiresMethodPhone = selectedMethod != null &&
        requiresMethodSpecificPhone(methodType);
    final showPhoneField = effectiveRequireAccount == true ||
        (effectiveRequireAccount != false &&
            ((requiresPhone && isETB) || requiresMethodPhone));

    final digits = _methodSpecificDigitsController.text.trim();
    final digitsValid = digits.length == 7 && RegExp(r'^\d{7}$').hasMatch(digits);

    String? effectivePhone;
    if (requiresMethodPhone) {
      if (methodType == PaymentMethodType.waafi && waafiPrefix != null && digitsValid) {
        effectivePhone = waafiPrefix + digits;
      } else if (methodType == PaymentMethodType.edahab && digitsValid) {
        effectivePhone = '65$digits';
      } else if (methodType == PaymentMethodType.ipay &&
          _ipayPhoneNumber != null &&
          _ipayPhoneNumber!.isNotEmpty) {
        effectivePhone = _ipayPhoneNumber!.replaceAll(RegExp(r'[^\d]'), '');
        if (effectivePhone.isEmpty) effectivePhone = null;
      } else {
        effectivePhone = null;
      }
    } else {
      if (showPhoneField && effectiveRequireAccount == true) {
        // requireAccountNumberOnInitiation: user must enter a valid phone number (no address fallback)
        if (_paymentPhoneNumber != null && _paymentPhoneNumber!.isNotEmpty) {
          effectivePhone = _paymentPhoneNumber!.replaceAll(RegExp(r'[^\d]'), '');
          if (effectivePhone.isEmpty || effectivePhone.length < 9) {
            effectivePhone = null;
          }
        } else {
          effectivePhone = null;
        }
      } else {
        effectivePhone = showPhoneField
            ? (_paymentPhoneNumber ?? phoneNumber)
            : null;
      }
    }

    final methodPhoneValid = !showPhoneField ||
        (requiresMethodPhone &&
            ((methodType == PaymentMethodType.waafi && digitsValid) ||
                (methodType == PaymentMethodType.edahab && digitsValid) ||
                (methodType == PaymentMethodType.ipay &&
                    (_ipayPhoneNumber?.isNotEmpty ?? false)))) ||
        (!requiresMethodPhone &&
            (effectivePhone != null && effectivePhone.isNotEmpty));

    final paymentInstructionText = requiresMethodPhone
        ? (_getSelectedVariant()?.paymentInstruction ??
            selectedMethod.paymentInstruction ??
            '')
        : '';

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          LocalizationService.t(context, 'checkout.selectPaymentMethod'),
          style: const TextStyle(
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
                    LocalizationService.t(context, 'checkout.choosePreferredPaymentMethod'),
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
                                child: Text(LocalizationService.t(context, 'cart.retry')),
                              ),
                            ],
                          ),
                        )
                      : _paymentMethodCategories.isEmpty
                      ? Center(
                          child: Text(LocalizationService.t(context, 'checkout.noPaymentMethodsAvailable')),
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
          // Phone number for payment (ETB mobile money or Waafi/Edahab/iPay)
          if (showPhoneField)
            Container(
              margin: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.phone_android_rounded,
                            size: 22,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                requiresMethodPhone
                                    ? LocalizationService.t(context, 'checkout.phoneNumberForPayment')
                                    : LocalizationService.t(context, 'checkout.mobileNumberForPayment'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 0.2,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                LocalizationService.t(context, 'checkout.enterNumberLinkedToAccount'),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      height: 1.3,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  if (requiresMethodPhone) ...[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (paymentInstructionText.isNotEmpty) ...[
                            Text(
                              LocalizationService.t(context, 'checkout.instructions'),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              paymentInstructionText,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                  ),
                            ),
                            const SizedBox(height: Spacing.md),
                          ],
                        ],
                      ),
                  ],
                  if (methodType == PaymentMethodType.waafi && waafiPrefix != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            '+$waafiPrefix ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _methodSpecificDigitsController,
                            keyboardType: TextInputType.number,
                            maxLength: 7,
                            decoration: InputDecoration(
                              hintText: '1234567',
                              counterText: '',
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
                              errorText: digits.isNotEmpty && !digitsValid
                                  ? 'Enter exactly 7 digits'
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                                vertical: Spacing.md,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    )
                  else if (methodType == PaymentMethodType.edahab)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            '+25265 ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _methodSpecificDigitsController,
                            keyboardType: TextInputType.number,
                            maxLength: 7,
                            decoration: InputDecoration(
                              hintText: '1234567',
                              counterText: '',
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
                              errorText: digits.isNotEmpty && !digitsValid
                                  ? 'Enter exactly 7 digits'
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                                vertical: Spacing.md,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    )
                  else if (methodType == PaymentMethodType.ipay)
                    IntlPhoneField(
                      onChanged: (phone) {
                        setState(() {
                          _ipayPhoneNumber = phone.completeNumber.isNotEmpty
                              ? phone.completeNumber
                              : null;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Phone number',
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.md,
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  else
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
                              (!methodPhoneValid ||
                                  effectivePhone == null ||
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
                      : Text(
                          LocalizationService.t(context, 'checkout.placeOrder'),
                          style: const TextStyle(
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
