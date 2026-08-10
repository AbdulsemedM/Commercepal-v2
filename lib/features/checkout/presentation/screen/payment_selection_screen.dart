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
import 'package:uuid/uuid.dart';
import '../../../../app/router/app_router.dart';
import '../../../addresses/data/models/address.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/data/models/cart.dart';
import '../../../cart/data/repository/cart_repository.dart';
import '../../data/models/checkout_request.dart';
import '../../data/models/checkout_response.dart';
import '../../data/models/payment_method_variant.dart';
import '../../data/models/payment_constants.dart';
import '../../data/models/payment_method_assets.dart';
import '../../data/repository/checkout_repository.dart';
import '../../data/repository/payment_methods_repository.dart';
import '../../data/repository/exchange_rates_repository.dart';
import '../../data/models/exchange_rates_response.dart';
import '../utils/payment_phone_utils.dart';
import '../utils/checkout_payment_navigation.dart';
import '../utils/checkout_error_utils.dart';
import '../widgets/payment_account_phone_field.dart';
import '../widgets/paypal_payment_summary.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_hint_banner.dart';

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
  final bool requiresAccount;

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
    this.requiresAccount = true,
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

  bool get _requiresPaymentPhone {
    final String? providerCode = _selectedPaymentProviderCode;
    if (providerCode == null || providerCode.isEmpty) return false;

    final _SelectablePaymentMethod? method = _getSelectedMethod();
    return PaymentConstants.shouldCollectPaymentAccount(
      providerCode,
      displayName: method?.displayName,
      apiRequiresAccount: method?.requiresAccount ?? false,
      legacyRequireAccountOnInitiation:
          method?.requireAccountNumberOnInitiation,
    );
  }

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
      final providers = await _paymentMethodsRepository.getSelectableProviders(
        cartCurrency: _cartCurrency,
      );

      final List<_SelectablePaymentMethod> selectable = providers
          .where((p) => _methodVisibleForCart(p.providerCode, _cartCurrency))
          .map(
            (p) => _SelectablePaymentMethod(
              id: p.providerCode,
              displayName: p.displayName,
              iconUrl: p.iconUrl,
              providerCode: p.providerCode,
              variantCode: p.providerCode,
              currency: _cartCurrency ?? '',
              hasVariants: false,
              requiresAccount: p.requiresAccount,
            ),
          )
          .toList();

      final List<_PaymentMethodCategory> categories = selectable.isEmpty
          ? <_PaymentMethodCategory>[]
          : <_PaymentMethodCategory>[
              _PaymentMethodCategory(
                categoryName: LocalizationService.t(
                  context,
                  'checkout.selectPaymentMethod',
                ),
                categoryCode: 'ALL',
                categoryIconUrl: '',
                methods: selectable,
              ),
            ];

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
    Address address,
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

      final bool needsPaymentAccount =
          PaymentConstants.shouldCollectPaymentAccount(
        paymentProviderCode,
        displayName: selectedMethod.displayName,
        apiRequiresAccount: selectedMethod.requiresAccount,
        legacyRequireAccountOnInitiation:
            selectedMethod.requireAccountNumberOnInitiation,
      );

      // Sahay: customer lookup, show customer name and confirm before placing order
      if (PaymentConstants.isSahay(paymentProviderCode)) {
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

      final String? paymentAccount;
      if (!needsPaymentAccount) {
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

      final Cart refreshedCart = await CartRepository().getCart();

      if (refreshedCart.items.isEmpty) {
        if (mounted) {
          setState(() => _isPlacingOrder = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                LocalizationService.t(context, 'checkout.invalidOrderData'),
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final List<CheckoutItem> checkoutItems = refreshedCart.items
          .map(
            (item) => CheckoutItem(
              itemId: item.productId,
              configId: item.configId,
              quantity: item.quantity,
            ),
          )
          .toList();

      final String checkoutProviderCode =
          PaymentConstants.toCheckoutProviderCode(paymentProviderCode);

      final checkoutRequest = CheckoutRequest(
        channel: PlatformUtils.getChannel(),
        currency: refreshedCart.currency,
        deliveryAddressId: address.id,
        items: checkoutItems,
        paymentProviderCode: checkoutProviderCode,
        paymentAccount: needsPaymentAccount ? paymentAccount : null,
        idempotencyKey: 'checkout-${const Uuid().v4()}',
        promoCode: null,
      );

      final response = await _checkoutRepository.checkout(checkoutRequest);

      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }

      if (!context.mounted) return;

      void onPaymentSuccess() =>
          context.read<CartBloc>().add(CartClearRequested());

      await navigateAfterCheckout(
        context,
        response: response,
        paymentProviderCode: checkoutProviderCode,
        paymentAccount: paymentAccount,
        onPaymentSuccess: response.isCheckoutCompleteForCartClear
            ? onPaymentSuccess
            : null,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });

        String errorMessage = mapCheckoutApiError(
          e,
          defaultMessage:
              LocalizationService.t(context, 'checkout.failedToPlaceOrder'),
          sessionExpiredMessage:
              LocalizationService.t(context, 'checkout.sessionExpired'),
          invalidOrderDataMessage:
              LocalizationService.t(context, 'checkout.invalidOrderData'),
          serverErrorMessage:
              LocalizationService.t(context, 'checkout.serverError'),
          serviceUnavailableMessage: LocalizationService.t(
            context,
            'checkout.serverError',
          ),
          conflictMessage: LocalizationService.t(
            context,
            'checkout.invalidOrderData',
          ),
        );
        if (errorMessage ==
            LocalizationService.t(context, 'checkout.failedToPlaceOrder')) {
          if (isUnauthorizedError(e)) {
            errorMessage =
                LocalizationService.t(context, 'checkout.sessionExpired');
          } else if (e.toString().isNotEmpty) {
            final errorStr = e.toString();
            if (errorStr.contains('Exception:')) {
              errorMessage = errorStr.split('Exception:').last.trim();
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
    // Get cart and address from route extra parameter
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final cart = extra?['cart'] as Cart?;
    final address = extra?['address'] as Address?;

    if (cart == null || address == null) {
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

    final bool canPlace = _selectedPaymentMethodId != null &&
        !_isPlacingOrder &&
        (_isPayPalSelected
            ? _paypalReadyForCheckout(cart.currency)
            : !_requiresPaymentPhone || isValidPaymentAccount(_paymentPhoneNumber));

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
          else if (!_requiresPaymentPhone)
            const SizedBox.shrink()
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
                          if (_isPayPalSelected ||
                              !_requiresPaymentPhone) {
                            _placeOrder(cart, address, null);
                          } else {
                            final phone = normalizePaymentAccount(
                              _paymentPhoneNumber!,
                            );
                            _placeOrder(cart, address, phone);
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
