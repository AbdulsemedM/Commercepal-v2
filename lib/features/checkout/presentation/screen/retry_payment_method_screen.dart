import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/services/localization_service.dart';
import '../../../../core/constants/country_currency_constants.dart';
import '../../../../core/design_system.dart';
import '../../../../core/widgets/checkout_screen_header.dart';
import '../../data/models/payment_retry_request.dart';
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

/// Helper to represent a selectable payment method for retry
class _SelectablePaymentMethod {
  final String id;
  final String displayName;
  final String? iconUrl;
  final String variantCode;
  final String currency;
  final bool hasVariants;
  final List<PaymentMethodVariant> variants;
  final bool? requireAccountNumberOnInitiation;
  final bool requiresAccount;

  _SelectablePaymentMethod({
    required this.id,
    required this.displayName,
    this.iconUrl,
    required this.variantCode,
    required this.currency,
    required this.hasVariants,
    this.variants = const [],
    this.requireAccountNumberOnInitiation,
    this.requiresAccount = true,
  });
}

class _PaymentMethodCategory {
  final String categoryName;
  final String categoryIconUrl;
  final List<_SelectablePaymentMethod> methods;

  _PaymentMethodCategory({
    required this.categoryName,
    required this.categoryIconUrl,
    required this.methods,
  });
}

/// Screen to choose another payment method when retrying a failed payment.
/// Calls POST /api/orders/{orderNumber}/retry-payment with selected method.
class RetryPaymentMethodScreen extends StatefulWidget {
  const RetryPaymentMethodScreen({
    super.key,
    required this.orderNumber,
    required this.currency,
    this.paymentReference,
    this.orderTotal,
  });

  final String orderNumber;
  final String currency;
  final String? paymentReference;
  final double? orderTotal;

  @override
  State<RetryPaymentMethodScreen> createState() =>
      _RetryPaymentMethodScreenState();
}

class _RetryPaymentMethodScreenState extends State<RetryPaymentMethodScreen> {
  final PaymentMethodsRepository _paymentMethodsRepository =
      PaymentMethodsRepository();
  final CheckoutRepository _checkoutRepository = CheckoutRepository();
  final ExchangeRatesRepository _exchangeRatesRepository =
      ExchangeRatesRepository();

  List<_PaymentMethodCategory> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedPaymentMethodId;
  String? _selectedVariantCode;
  ExchangeRatesData? _exchangeRates;
  bool _isLoadingExchangeRates = false;
  String? _exchangeRatesError;
  final TextEditingController _paymentPhoneController = TextEditingController();
  String? _paymentPhoneNumber;
  String _initialCountryCode = 'ET';
  bool _paymentPhonePrefilled = false;

  bool _currencyMatches(String? methodCurrency) {
    if (widget.currency.isEmpty || methodCurrency == null) return true;
    return widget.currency.toUpperCase() == methodCurrency.toUpperCase();
  }

  bool _methodVisibleForCart(String itemCode, String? methodCurrency) {
    if (PaymentConstants.isPayPal(itemCode) &&
        PaymentConstants.isPayPalSupportedCartCurrency(widget.currency)) {
      return true;
    }
    return _currencyMatches(methodCurrency);
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

  bool _paypalReadyForCheckout() {
    if (!_isPayPalSelected) return true;
    final String code = widget.currency.toUpperCase();
    if (code == 'USD') return true;
    return !_isLoadingExchangeRates &&
        _exchangeRatesError == null &&
        _exchangeRates != null &&
        _exchangeRates!.hasRateFor(code);
  }

  Future<void> _loadExchangeRatesIfNeeded() async {
    if (!PaymentConstants.isPayPalSupportedCartCurrency(widget.currency)) {
      return;
    }
    if (widget.currency.toUpperCase() == 'USD') {
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

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final providers = await _paymentMethodsRepository.getSelectableProviders(
        cartCurrency: widget.currency,
      );
      final List<_SelectablePaymentMethod> selectable = providers
          .where((p) => _methodVisibleForCart(p.providerCode, widget.currency))
          .map(
            (p) => _SelectablePaymentMethod(
              id: p.providerCode,
              displayName: p.displayName,
              iconUrl: p.iconUrl,
              variantCode: p.providerCode,
              currency: widget.currency,
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
                categoryIconUrl: '',
                methods: selectable,
              ),
            ];

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = LocalizationService.t(
              context, 'checkout.failedToLoadPaymentMethods');
        });
        AppSnackbars.error(
          context,
          context.tr('checkout.failedToLoadPaymentMethods'),
        );
      }
    }
  }

  _SelectablePaymentMethod? _getSelectedMethod() {
    if (_selectedPaymentMethodId == null) return null;
    for (final cat in _categories) {
      try {
        return cat.methods.firstWhere((m) => m.id == _selectedPaymentMethodId);
      } catch (_) {}
    }
    return null;
  }

  Future<void> _showVariantDialog(_SelectablePaymentMethod method) async {
    final selected = await showDialog<PaymentMethodVariant>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(method.displayName),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: method.variants.length,
            itemBuilder: (context, index) {
              final v = method.variants[index];
              return ListTile(
                leading: PaymentMethodAssets.logo(
                  size: 40,
                  name: v.displayName,
                  code: v.variantCode,
                  iconUrl: v.iconUrl,
                ),
                title: Text(v.displayName),
                onTap: () => Navigator.of(context).pop(v),
              );
            },
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _selectedPaymentMethodId = method.id;
        _selectedVariantCode = selected.variantCode;
      });
    }
  }

  /// Guards against double taps sending the retry twice.
  bool _isSubmitting = false;

  Future<void> _onPayPressed() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await _payWithSelectedMethod();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _payWithSelectedMethod() async {
    final method = _getSelectedMethod();
    if (method == null) return;

    final variantCode =
        method.hasVariants ? (_selectedVariantCode ?? '') : method.variantCode;
    if (method.hasVariants && (variantCode.isEmpty)) {
      AppSnackbars.info(
        context,
        context.tr('checkout.pleaseSelectPaymentOption'),
      );
      return;
    }

    // Selected option's item code (for request; no variant code field)
    final paymentProviderCode =
        method.hasVariants && _selectedVariantCode != null
            ? _selectedVariantCode!
            : method.id;

    final bool needsPaymentAccount =
        PaymentConstants.shouldCollectPaymentAccount(
      paymentProviderCode,
      displayName: method.displayName,
      apiRequiresAccount: method.requiresAccount,
      legacyRequireAccountOnInitiation: method.requireAccountNumberOnInitiation,
    );

    String? paymentAccount;
    if (!needsPaymentAccount) {
      paymentAccount = null;
    } else {
      if (!isValidPaymentAccount(_paymentPhoneNumber)) {
        AppSnackbars.info(
          context,
          context.tr('checkout.pleaseEnterValidPhone'),
        );
        return;
      }
      paymentAccount = normalizePaymentAccount(_paymentPhoneNumber!);
    }

    // Sahay: customer lookup, show customer name and confirm before retrying payment
    if (PaymentConstants.isSahay(paymentProviderCode)) {
      try {
        final lookup =
            await _checkoutRepository.verifySahayAccount(paymentAccount!);
        if (!mounted) return;
        if (!lookup.success) {
          AppSnackbars.error(
            context,
            lookup.message ??
                context.tr('checkout.phoneNumberCouldNotBeVerified'),
          );
          return;
        }
        final customerName = lookup.customerName ?? lookup.accountHolderName;
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title:
                Text(LocalizationService.t(ctx, 'checkout.sahayConfirmTitle')),
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
                child:
                    Text(LocalizationService.t(ctx, 'checkout.sahayConfirm')),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (confirmed != true) return;
      } catch (e) {
        if (mounted) {
          String msg =
              LocalizationService.t(context, 'checkout.verificationFailed');
          if (e is DioException && e.response?.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            final apiMessage = data['message'] as String?;
            if (apiMessage != null && apiMessage.isNotEmpty) msg = apiMessage;
          }
          AppSnackbars.error(context, msg);
        }
        return;
      }
    }

    setState(() => _errorMessage = null);
    try {
      final String orderNumber = widget.orderNumber.trim();
      if (orderNumber.isEmpty) {
        throw Exception('Missing order number');
      }

      final String checkoutProviderCode =
          PaymentConstants.toCheckoutProviderCode(paymentProviderCode);
      final request = PaymentRetryRequest(
        paymentProviderCode: checkoutProviderCode,
        paymentAccount: paymentAccount,
      );
      final updated = await _checkoutRepository.retryPayment(
        orderNumber: orderNumber,
        request: request,
      );
      if (!mounted) return;

      await navigateAfterRetryPaymentSuccess(
        context,
        updated,
        paymentProviderCode: checkoutProviderCode,
        paymentAccount: paymentAccount,
      );
      if (mounted) context.pop(updated);
    } catch (e) {
      if (mounted) {
        String msg =
            LocalizationService.t(context, 'checkout.failedToRetryPayment');
        if (e is DioException && e.response?.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          final apiMessage = data['message'] as String?;
          if (apiMessage != null && apiMessage.isNotEmpty) msg = apiMessage;
        }
        AppSnackbars.error(context, msg);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _loadExchangeRatesIfNeeded();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillPaymentPhone());
  }

  Future<void> _prefillPaymentPhone() async {
    if (_paymentPhonePrefilled || !mounted) return;

    final raw = await loadDefaultPaymentPhone();
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
    _paymentPhoneController.dispose();
    super.dispose();
  }

  List<_SelectablePaymentMethod> get _allSelectableMethods => [
        for (final category in _categories) ...category.methods,
      ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    // orderNumber is non-nullable, so the title always names the order.
    final String title =
        '${context.tr('checkout.payOrder')} ${widget.orderNumber}';

    final bool canPay = _getSelectedMethod() != null &&
        (_isPayPalSelected
            ? _paypalReadyForCheckout()
            : !_requiresPaymentPhone ||
                isValidPaymentAccount(_paymentPhoneNumber));

    final Widget body;
    if (_isLoading) {
      body = Semantics(
        label: context.tr('checkout.retry.loadingMethods'),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: List<Widget>.generate(
            5,
            (_) => const ListTileShimmer(leadingSize: 48),
          ),
        ),
      );
    } else if (_categories.isEmpty) {
      body = AppEmptyState(
        isError: _errorMessage != null,
        icon: Icons.credit_card_off_outlined,
        title: _errorMessage ??
            context.tr('checkout.noPaymentMethodsAvailableRetry'),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.sm,
                Spacing.gutter,
                Spacing.gutter,
              ),
              itemCount: _allSelectableMethods.length + 1,
              separatorBuilder: (_, int index) => SizedBox(
                height: index == 0 ? Spacing.sm : Spacing.xs,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    context.tr('checkout.selectPaymentMethodToRetry'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  );
                }
                final method = _allSelectableMethods[index - 1];
                return PaymentMethodCard(
                  paymentMethodId: method.id,
                  paymentMethodName: method.displayName,
                  iconUrl: method.iconUrl,
                  isSelected: _selectedPaymentMethodId == method.id,
                  glow: PaymentConstants.isQPay(
                    method.id,
                    displayName: method.displayName,
                  ),
                  onTap: () {
                    if (method.hasVariants) {
                      _showVariantDialog(method);
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
          ),
          if (_isPayPalSelected && widget.orderTotal != null)
            PayPalPaymentSummary(
              cartCurrency: widget.currency,
              orderTotal: widget.orderTotal!,
              exchangeRates: _exchangeRates,
              isLoading: _isLoadingExchangeRates &&
                  widget.currency.toUpperCase() != 'USD',
              errorMessage: widget.currency.toUpperCase() != 'USD'
                  ? _exchangeRatesError
                  : null,
            )
          else if (_requiresPaymentPhone)
            PaymentAccountPhoneField(
              controller: _paymentPhoneController,
              initialCountryCode: _initialCountryCode,
              onChanged: (value) {
                setState(() {
                  _paymentPhoneNumber = value;
                });
              },
            ),
          const SizedBox(height: Spacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(top: BorderSide(color: context.commerce.border)),
            ),
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
                  if (widget.orderTotal != null) ...[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            context.tr('checkout.totalDue'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        PriceTag(
                          amount: widget.orderTotal!,
                          currency: CountryCurrencyConstants.getCurrencySymbol(
                            widget.currency,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                  ],
                  AppButton.primary(
                    label: context.tr('checkout.payWithThisMethod'),
                    icon: Icons.lock_outline_rounded,
                    loading: _isSubmitting,
                    onPressed: canPay ? _onPayPressed : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CheckoutScreenHeader(title: title),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
