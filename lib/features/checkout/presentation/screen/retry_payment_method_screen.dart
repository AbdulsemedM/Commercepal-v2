import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/services/localization_service.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/widgets/checkout_screen_header.dart';
import '../../data/models/checkout_response.dart';
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
import 'ussd_payment_success_screen.dart';

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

  _SelectablePaymentMethod({
    required this.id,
    required this.displayName,
    this.iconUrl,
    required this.variantCode,
    required this.currency,
    required this.hasVariants,
    this.variants = const [],
    this.requireAccountNumberOnInitiation,
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
/// Calls POST /api/v1/payments/retry with selected method and pops with
/// [CheckoutResponse] on success.
class RetryPaymentMethodScreen extends StatefulWidget {
  const RetryPaymentMethodScreen({
    super.key,
    required this.paymentReference,
    required this.currency,
    this.orderNumber,
    this.orderTotal,
  });

  final String paymentReference;
  final String currency;
  final String? orderNumber;
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
      final response = await _paymentMethodsRepository.getPaymentMethods();
      final List<_PaymentMethodCategory> categories = [];

      // Item codes already exposed through nested items, so duplicate
      // top-level entries (e.g. PESAPAL_CARD) are skipped.
      final Set<String> nestedItemCodes = {
        for (final method in response.data)
          for (final item in method.paymentMethodItemResponses) item.itemCode,
      };

      for (final paymentMethod in response.data) {
        final List<_SelectablePaymentMethod> methods = [];

        // Some methods (Telebirr, CBE Birr, QPay, Amole, â€¦) come with no inner
        // items; the top-level method itself is the selectable option.
        if (paymentMethod.paymentMethodItemResponses.isEmpty) {
          if (nestedItemCodes.contains(paymentMethod.code)) continue;
          if (!_methodVisibleForCart(
            paymentMethod.code,
            widget.currency,
          )) {
            continue;
          }
          categories.add(
            _PaymentMethodCategory(
              categoryName: paymentMethod.displayName,
              categoryIconUrl: paymentMethod.iconUrl,
              methods: [
                _SelectablePaymentMethod(
                  id: paymentMethod.code,
                  displayName: paymentMethod.displayName,
                  iconUrl: paymentMethod.iconUrl,
                  variantCode: paymentMethod.code,
                  currency: widget.currency,
                  hasVariants: false,
                ),
              ],
            ),
          );
          continue;
        }

        for (final item in paymentMethod.paymentMethodItemResponses) {
          if (item.hasVariants) {
            final matchingVariants = item.paymentMethodItemResponses
                .where((v) => _methodVisibleForCart(v.variantCode, v.currency))
                .toList();
            if (matchingVariants.isEmpty) continue;
            methods.add(
              _SelectablePaymentMethod(
                id: item.itemCode,
                displayName: item.displayName,
                iconUrl: item.iconUrl,
                variantCode: item.itemCode,
                currency: item.currency,
                hasVariants: true,
                variants: matchingVariants,
                requireAccountNumberOnInitiation:
                    item.requireAccountNumberOnInitiation,
              ),
            );
          } else {
            if (!_methodVisibleForCart(item.itemCode, item.currency)) continue;
            methods.add(
              _SelectablePaymentMethod(
                id: item.itemCode,
                displayName: item.displayName,
                iconUrl: item.iconUrl,
                variantCode: item.itemCode,
                currency: item.currency,
                hasVariants: false,
                requireAccountNumberOnInitiation:
                    item.requireAccountNumberOnInitiation,
              ),
            );
          }
        }

        if (methods.isNotEmpty) {
          categories.add(
            _PaymentMethodCategory(
              categoryName: paymentMethod.displayName,
              categoryIconUrl: paymentMethod.iconUrl,
              methods: methods,
            ),
          );
        }
      }

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
          _errorMessage = LocalizationService.t(context, 'checkout.failedToLoadPaymentMethods');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.t(context, 'checkout.failedToLoadPaymentMethods')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  _SelectablePaymentMethod? _getSelectedMethod() {
    if (_selectedPaymentMethodId == null) return null;
    for (final cat in _categories) {
      try {
        return cat.methods
            .firstWhere((m) => m.id == _selectedPaymentMethodId);
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

  Future<void> _payWithSelectedMethod() async {
    final method = _getSelectedMethod();
    if (method == null) return;

    final variantCode = method.hasVariants
        ? (_selectedVariantCode ?? '')
        : method.variantCode;
    if (method.hasVariants && (variantCode.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationService.t(context, 'checkout.pleaseSelectPaymentOption')),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Selected option's item code (for request; no variant code field)
    final paymentProviderCode = method.hasVariants && _selectedVariantCode != null
        ? _selectedVariantCode!
        : method.id;

    final bool isPayPal = PaymentConstants.isPayPal(paymentProviderCode);

    String? paymentAccount;
    if (isPayPal) {
      paymentAccount = null;
    } else {
      if (!isValidPaymentAccount(_paymentPhoneNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.t(context, 'checkout.pleaseEnterValidPhone')),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      paymentAccount = normalizePaymentAccount(_paymentPhoneNumber!);
    }

    // Sahay: customer lookup, show customer name and confirm before retrying payment
    if (paymentProviderCode == PaymentConstants.sahayProviderCode) {
      try {
        final lookup = await _checkoutRepository.verifySahayAccount(paymentAccount!);
        if (!mounted) return;
        if (!lookup.success) {
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
        if (confirmed != true) return;
      } catch (e) {
        if (mounted) {
          String msg = LocalizationService.t(context, 'checkout.verificationFailed');
          if (e is DioException && e.response?.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            final apiMessage = data['message'] as String?;
            if (apiMessage != null && apiMessage.isNotEmpty) msg = apiMessage;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppColors.error),
          );
        }
        return;
      }
    }

    setState(() => _errorMessage = null);
    try {
      final request = PaymentRetryRequest(
        paymentReference: widget.paymentReference,
        paymentProviderCode: paymentProviderCode,
        paymentAccount: paymentAccount,
      );
      final updated = await _checkoutRepository.retryPayment(request);
      if (!mounted) return;

      // For USSD (Telebirr, etc.): push initiation confirmation before webview
      if (PaymentConstants.isUssdPaymentProvider(paymentProviderCode)) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => UssdPaymentSuccessScreen(
              orderNumber: updated.orderNumber ?? widget.orderNumber,
            ),
          ),
        );
        if (!mounted) return;
      }

      final init = updated.paymentInitiation;
      final nextAction = init?.nextAction?.trim() ?? '';
      final paymentUrl = init?.paymentUrl?.trim() ?? '';

      if (nextAction == CheckoutResponse.nextActionScanQr &&
          paymentUrl.isNotEmpty) {
        navigateAfterRetryPaymentSuccess(context, updated);
        return;
      }

      if (nextAction == CheckoutResponse.nextActionRedirectToPaymentUrl &&
          paymentUrl.isNotEmpty) {
        context.push(
          AppRoutes.paymentWebView,
          extra: <String, dynamic>{
            'paymentUrl': paymentUrl,
            'orderNumber': updated.orderNumber,
          },
        );
      }
      if (mounted) context.pop(updated);
    } catch (e) {
      if (mounted) {
        String msg = LocalizationService.t(context, 'checkout.failedToRetryPayment');
        if (e is DioException && e.response?.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          final apiMessage = data['message'] as String?;
          if (apiMessage != null && apiMessage.isNotEmpty) msg = apiMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
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
    final title = widget.orderNumber != null
        ? '${LocalizationService.t(context, 'checkout.payOrder')} ${widget.orderNumber}'
        : LocalizationService.t(context, 'checkout.selectPaymentMethod');

    final phoneValid = isValidPaymentAccount(_paymentPhoneNumber);
    final bool canPay = _getSelectedMethod() != null &&
        (_isPayPalSelected ? _paypalReadyForCheckout() : phoneValid);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CheckoutScreenHeader(title: title),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.lg),
                            child: Text(
                              _errorMessage ??
                                  LocalizationService.t(
                                    context,
                                    'checkout.noPaymentMethodsAvailableRetry',
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Column(
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
                                      LocalizationService.t(
                                        context,
                                        'checkout.selectPaymentMethodToRetry',
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: Colors.black54),
                                    ),
                                  ),
                                  Expanded(
                                    child: GridView.builder(
                                      padding:
                                          const EdgeInsets.all(Spacing.md),
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
                                          paymentMethodName:
                                              method.displayName,
                                          iconUrl: method.iconUrl,
                                          isSelected:
                                              _selectedPaymentMethodId ==
                                                  method.id,
                                          onTap: () {
                                            if (method.hasVariants) {
                                              _showVariantDialog(method);
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
                            if (_isPayPalSelected && widget.orderTotal != null)
                              PayPalPaymentSummary(
                                cartCurrency: widget.currency,
                                orderTotal: widget.orderTotal!,
                                exchangeRates: _exchangeRates,
                                isLoading: _isLoadingExchangeRates &&
                                    widget.currency.toUpperCase() != 'USD',
                                errorMessage:
                                    widget.currency.toUpperCase() != 'USD'
                                        ? _exchangeRatesError
                                        : null,
                              )
                            else if (!_isPayPalSelected)
                              PaymentAccountPhoneField(
                                controller: _paymentPhoneController,
                                initialCountryCode: _initialCountryCode,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentPhoneNumber = value;
                                  });
                                },
                              ),
                            Padding(
                              padding: const EdgeInsets.all(Spacing.md),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: canPay
                                      ? AppDecorations.primaryCtaGradient
                                      : null,
                                  color: canPay ? null : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: canPay
                                      ? <BoxShadow>[
                                          BoxShadow(
                                            color: AppColors.pink
                                                .withOpacity(0.35),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: canPay
                                        ? _payWithSelectedMethod
                                        : null,
                                    borderRadius: BorderRadius.circular(28),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Spacing.md + 2,
                                      ),
                                      child: Center(
                                        child: Text(
                                          LocalizationService.t(
                                            context,
                                            'checkout.payWithThisMethod',
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: canPay
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
          ],
        ),
      ),
    );
  }
}
