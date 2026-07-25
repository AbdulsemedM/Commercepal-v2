import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/auth/session_error.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/widgets/checkout_step_indicator.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../../../app/router/app_router.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/data/models/cart.dart';
import '../../data/models/checkout_request.dart';
import '../../data/models/payment_method_variant.dart';
import '../../data/models/payment_constants.dart';
import '../../data/models/payment_method_assets.dart';
import '../../data/repository/checkout_repository.dart';
import '../../data/repository/payment_methods_repository.dart';
import '../../data/repository/exchange_rates_repository.dart';
import '../../data/models/exchange_rates_response.dart';
import '../utils/payment_phone_utils.dart';
import '../utils/checkout_payment_navigation.dart';
import '../widgets/payment_account_phone_field.dart';
import '../widgets/paypal_payment_summary.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_hint_banner.dart';
import 'checkout_initiation_failed_screen.dart';

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

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedPaymentMethodId;
  String? _selectedVariantCode; // Store selected variant code separately
  bool _isPlacingOrder = false;
  bool _isLoadingPaymentMethods = true;
  String? _errorMessage;
  String? _cartCurrency; // Cart currency for filtering payment methods (e.g. ETB, USD)
  final CheckoutRepository _checkoutRepository = CheckoutRepository();
  final PaymentMethodsRepository _paymentMethodsRepository =
      PaymentMethodsRepository();
  final ExchangeRatesRepository _exchangeRatesRepository =
      ExchangeRatesRepository();
  List<_PaymentMethodCategory> _paymentMethodCategories = [];
  bool _paymentMethodsLoadStarted = false;
  ExchangeRatesData? _exchangeRates;
  bool _isLoadingExchangeRates = false;
  String? _exchangeRatesError;
  final TextEditingController _paymentPhoneController = TextEditingController();
  String? _paymentPhoneNumber;
  String _initialCountryCode = 'ET';
  bool _paymentPhonePrefilled = false;
  late final PaymentHintController _paymentHint;

  @override
  void initState() {
    super.initState();
    _paymentHint = PaymentHintController(vsync: this);
    _paymentHint.startIntro();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillPaymentPhone());
  }

  Future<void> _prefillPaymentPhone() async {
    if (_paymentPhonePrefilled || !mounted) return;

    final extra = GoRouterState.of(context).extra;
    final fallbackPhone = extra is Map<String, dynamic>
        ? extra['phoneNumber'] as String?
        : null;

    final raw = await loadDefaultPaymentPhone(fallbackPhone: fallbackPhone);
    if (!mounted || raw == null || raw.isEmpty) return;

    final parsed = parseProfilePhoneForField(raw);
    setState(() {
      _paymentPhonePrefilled = true;
      _initialCountryCode = parsed.initialCountryCode;
      _paymentPhoneController.text = parsed.localNumber;
      _paymentPhoneNumber = parsed.completeNumber;
    });
  }

  @override
  void dispose() {
    _paymentHint.dispose();
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
      _loadExchangeRatesIfNeeded();
    }
  }

  bool _currencyMatches(String? methodCurrency) {
    if (_cartCurrency == null || methodCurrency == null) return true;
    return _cartCurrency!.toUpperCase() == methodCurrency.toUpperCase();
  }

  bool _methodVisibleForCart(String itemCode, String? methodCurrency) {
    if (PaymentConstants.isPayPal(itemCode) &&
        PaymentConstants.isPayPalSupportedCartCurrency(_cartCurrency)) {
      return true;
    }
    return _currencyMatches(methodCurrency);
  }

  _SelectablePaymentMethod? _getSelectedMethod() {
    if (_selectedPaymentMethodId == null) return null;
    for (final category in _paymentMethodCategories) {
      for (final method in category.methods) {
        if (method.id == _selectedPaymentMethodId) {
          return method;
        }
      }
    }
    return null;
  }

  String? get _selectedPaymentProviderCode {
    final method = _getSelectedMethod();
    if (method == null) return null;
    return method.hasVariants && _selectedVariantCode != null
        ? _selectedVariantCode
        : method.id;
  }

  bool get _isPayPalSelected =>
      PaymentConstants.isPayPal(_selectedPaymentProviderCode);

  bool _paypalReadyForCheckout(String cartCurrency) {
    if (!_isPayPalSelected) return true;
    final String code = cartCurrency.toUpperCase();
    if (code == 'USD') return true;
    return !_isLoadingExchangeRates &&
        _exchangeRatesError == null &&
        _exchangeRates != null &&
        _exchangeRates!.hasRateFor(code);
  }

  Future<void> _loadExchangeRatesIfNeeded() async {
    if (!PaymentConstants.isPayPalSupportedCartCurrency(_cartCurrency)) {
      return;
    }
    if (_cartCurrency!.toUpperCase() == 'USD') {
      return;
    }
    setState(() {
      _isLoadingExchangeRates = true;
      _exchangeRatesError = null;
    });
    try {
      final rates = await _exchangeRatesRepository.getExchangeRates();
      if (!mounted) return;
      setState(() {
        _exchangeRates = rates;
        _isLoadingExchangeRates = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingExchangeRates = false;
        _exchangeRatesError = LocalizationService.t(
          context,
          'checkout.paypalRatesUnavailable',
        );
      });
    }
  }

  /// Flat list of every selectable method across categories (for the grid).
  List<_SelectablePaymentMethod> get _allSelectableMethods => [
        for (final category in _paymentMethodCategories) ...category.methods,
      ];

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoadingPaymentMethods = true;
      _errorMessage = null;
    });

    try {
      final response = await _paymentMethodsRepository.getPaymentMethods();

      // Build payment methods structure grouped by categories, filtered by cart currency
      final List<_PaymentMethodCategory> categories = [];

      // Item codes already exposed through nested items (e.g. PesaPal's
      // PESAPAL_CARD / PESAPAL_MPESA) so duplicate top-level entries are skipped.
      final Set<String> nestedItemCodes = {
        for (final method in response.data)
          for (final item in method.paymentMethodItemResponses) item.itemCode,
      };

      for (final paymentMethod in response.data) {
        final List<_SelectablePaymentMethod> categoryMethods = [];

        // Some methods (CBE Birr, QPay, Amole, …) come with no inner
        // items; the top-level method itself is the selectable option.
        if (paymentMethod.paymentMethodItemResponses.isEmpty) {
          if (nestedItemCodes.contains(paymentMethod.code)) continue;
          if (PaymentConstants.isHiddenPaymentProvider(
            paymentMethod.code,
            displayName: paymentMethod.displayName,
          )) {
            continue;
          }
          if (!_methodVisibleForCart(
            paymentMethod.code,
            _cartCurrency,
          )) {
            continue;
          }
          categories.add(
            _PaymentMethodCategory(
              categoryName: paymentMethod.displayName,
              categoryCode: paymentMethod.code,
              categoryIconUrl: paymentMethod.iconUrl,
              methods: [
                _SelectablePaymentMethod(
                  id: paymentMethod.code,
                  displayName: paymentMethod.displayName,
                  iconUrl: paymentMethod.iconUrl,
                  providerCode: paymentMethod.code,
                  variantCode: paymentMethod.code,
                  currency: _cartCurrency ?? '',
                  hasVariants: false,
                ),
              ],
            ),
          );
          continue;
        }

        for (final item in paymentMethod.paymentMethodItemResponses) {
          if (PaymentConstants.isHiddenPaymentProvider(
            item.itemCode,
            displayName: item.displayName,
          )) {
            continue;
          }
          if (item.hasVariants) {
            // Filter variants by cart currency; only show method if at least one variant matches
            final matchingVariants = item.paymentMethodItemResponses
                .where(
                  (v) =>
                      !PaymentConstants.isHiddenPaymentProvider(
                        v.variantCode,
                        displayName: v.displayName,
                      ) &&
                      _methodVisibleForCart(v.variantCode, v.currency),
                )
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
            if (!_methodVisibleForCart(item.itemCode, item.currency)) continue;
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
                leading: PaymentMethodAssets.logo(
                  size: 40,
                  name: variant.displayName,
                  code: variant.variantCode,
                  iconUrl: variant.iconUrl,
                ),
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

      final bool isPayPal = PaymentConstants.isPayPal(paymentProviderCode);

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

      // Convert cart items to checkout items (include unitPrice like web checkout)
      final checkoutItems = cart.items.map((item) {
        final price = item.unitPrice > 0 ? item.unitPrice : item.currentPrice;
        return CheckoutItem(
          itemId: item.productId,
          configId: item.configId,
          quantity: item.quantity,
          unitPrice: price,
        );
      }).toList();

      final String? paymentAccount;
      if (isPayPal) {
        paymentAccount = null;
      } else {
        paymentAccount = phoneNumber != null && phoneNumber.isNotEmpty
            ? normalizePaymentAccount(phoneNumber)
            : null;

        if (paymentAccount == null || !isValidPaymentAccount(phoneNumber)) {
          if (mounted) {
            setState(() => _isPlacingOrder = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocalizationService.t(context, 'checkout.pleaseEnterValidPhone'),
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          }
          return;
        }
      }

      final checkoutRequest = CheckoutRequest(
        channel: PlatformUtils.getChannel(),
        currency: cart.currency,
        deliveryAddressId: addressId,
        items: checkoutItems,
        paymentProviderCode: paymentProviderCode,
        paymentAccount: PaymentConstants.isCashOnDelivery(paymentProviderCode)
            ? null
            : paymentAccount,
      );

      // Call checkout API
      final response = await _checkoutRepository.checkout(checkoutRequest);

      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }

      if (!context.mounted) return;

      if (PaymentConstants.isCashOnDelivery(paymentProviderCode) &&
          (response.resolvedOrderNumber?.isNotEmpty ?? false)) {
        navigateToCashOnDeliverySuccess(
          context,
          response,
          onAfterNavigate: () =>
              context.read<CartBloc>().add(CartClearRequested()),
        );
        return;
      }

      if (response.isCheckoutCompleteForCartClear) {
        navigateAfterCheckoutSuccess(
          context,
          response,
          onAfterNavigate: () =>
              context.read<CartBloc>().add(CartClearRequested()),
        );
        return;
      }

      // Order created (HTTP 200) but payment still pending / initiation failed —
      // show pending details and direct user to order history to pay later.
      if (response.isOrderReservedPaymentPending) {
        navigateToPaymentPending(
          context,
          response,
          onAfterNavigate: () =>
              context.read<CartBloc>().add(CartClearRequested()),
        );
        return;
      }

      final ref = response.paymentReferenceOrNull;
      final ord = response.resolvedOrderNumber;
      if (ref != null &&
          ref.isNotEmpty &&
          ord != null &&
          ord.isNotEmpty) {
        await context.push<void>(
          AppRoutes.retryPaymentMethod,
          extra: <String, dynamic>{
            'paymentReference': ref,
            'currency': cart.currency,
            'orderNumber': ord,
            'orderTotal': response.pricingSummary?.totalAmount?.toDouble() ??
                cart.estimatedTotal,
          },
        );
      } else {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext ctx) => CheckoutInitiationFailedScreen(
              message: LocalizationService.t(
                ctx,
                'checkout.initiationFailedGeneric',
              ),
            ),
          ),
        );
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
          if (isUnauthorizedError(e)) {
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
    // Get cart and addressId from route extra parameter
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final cart = extra?['cart'] as Cart?;
    final addressId = extra?['addressId'] as int?;

    if (cart == null || addressId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              CheckoutScreenHeader(
                title: LocalizationService.t(context, 'checkout.payment'),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    LocalizationService.t(
                      context,
                      'checkout.missingCheckoutData',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final phoneValid = isValidPaymentAccount(_paymentPhoneNumber);
    final bool canPlace = _selectedPaymentMethodId != null &&
        !_isPlacingOrder &&
        (_isPayPalSelected
            ? _paypalReadyForCheckout(cart.currency)
            : phoneValid);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CheckoutScreenHeader(
              title: LocalizationService.t(
                context,
                'checkout.selectPaymentMethod',
              ),
              trailing: _paymentHint.buildIcon(),
            ),
            CheckoutStepIndicator(
              currentStep: 2,
              totalSteps: 3,
              labels: <String>[
                LocalizationService.t(context, 'checkout.stepCart'),
                LocalizationService.t(context, 'checkout.stepPayment'),
                LocalizationService.t(context, 'checkout.stepConfirm'),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _paymentHint.buildBanner(
                    message: LocalizationService.t(
                      context,
                      'checkout.choosePreferredPaymentMethod',
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
                                      child: Text(
                                        LocalizationService.t(
                                          context,
                                          'cart.retry',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _paymentMethodCategories.isEmpty
                                ? Center(
                                    child: Text(
                                      LocalizationService.t(
                                        context,
                                        'checkout.noPaymentMethodsAvailable',
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(Spacing.md),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: Spacing.sm,
                                      mainAxisSpacing: Spacing.sm,
                                      childAspectRatio: 0.85,
                                    ),
                                    itemCount: _allSelectableMethods.length,
                                    itemBuilder: (context, index) {
                                      final method =
                                          _allSelectableMethods[index];
                                      return PaymentMethodCard(
                                        paymentMethodId: method.id,
                                        paymentMethodName: method.displayName,
                                        iconUrl: method.iconUrl,
                                        isSelected:
                                            _selectedPaymentMethodId ==
                                                method.id,
                                        glow: PaymentConstants.isQPay(
                                          method.id,
                                          displayName: method.displayName,
                                        ),
                                        onTap: () {
                                          if (method.hasVariants) {
                                            _showVariantSelectionDialog(
                                              context,
                                              method,
                                            );
                                          } else {
                                            setState(() {
                                              _selectedPaymentMethodId =
                                                  method.id;
                                              _selectedVariantCode = null;
                                            });
                                          }
                                        },
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          if (_isPayPalSelected)
            PayPalPaymentSummary(
              cartCurrency: cart.currency,
              orderTotal: cart.estimatedTotal,
              exchangeRates: _exchangeRates,
              isLoading: _isLoadingExchangeRates &&
                  cart.currency.toUpperCase() != 'USD',
              errorMessage: cart.currency.toUpperCase() != 'USD'
                  ? _exchangeRatesError
                  : null,
            )
          else
            PaymentAccountPhoneField(
              controller: _paymentPhoneController,
              initialCountryCode: _initialCountryCode,
              onChanged: (value) {
                setState(() {
                  _paymentPhoneNumber = value;
                });
              },
            ),
          // Place Order Button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.md,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: canPlace ? AppDecorations.primaryCtaGradient : null,
                color: canPlace ? null : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(28),
                boxShadow: canPlace
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.pink.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canPlace
                      ? () {
                          if (_isPayPalSelected) {
                            _placeOrder(cart, addressId, null);
                          } else {
                            final phone = normalizePaymentAccount(
                              _paymentPhoneNumber!,
                            );
                            _placeOrder(cart, addressId, phone);
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.md + 2,
                    ),
                    child: Center(
                      child: _isPlacingOrder
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              LocalizationService.t(
                                context,
                                'checkout.placeOrder',
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: canPlace
                                    ? Colors.white
                                    : Colors.grey.shade600,
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
    );
  }
}
