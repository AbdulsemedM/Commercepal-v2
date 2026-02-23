import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../data/models/checkout_response.dart';
import '../../data/models/payment_retry_request.dart';
import '../../data/models/payment_method_type.dart';
import '../../data/models/payment_method_variant.dart';
import '../../data/repository/checkout_repository.dart';
import '../../data/repository/payment_methods_repository.dart';
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

  _SelectablePaymentMethod({
    required this.id,
    required this.displayName,
    this.iconUrl,
    required this.variantCode,
    required this.currency,
    required this.hasVariants,
    this.variants = const [],
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
  });

  final String paymentReference;
  final String currency;
  final String? orderNumber;

  @override
  State<RetryPaymentMethodScreen> createState() =>
      _RetryPaymentMethodScreenState();
}

class _RetryPaymentMethodScreenState extends State<RetryPaymentMethodScreen> {
  final PaymentMethodsRepository _paymentMethodsRepository =
      PaymentMethodsRepository();
  final CheckoutRepository _checkoutRepository = CheckoutRepository();

  List<_PaymentMethodCategory> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedPaymentMethodId;
  String? _selectedVariantCode;
  final TextEditingController _methodSpecificDigitsController =
      TextEditingController();
  String? _ipayPhoneNumber;

  bool _currencyMatches(String? methodCurrency) {
    if (widget.currency.isEmpty || methodCurrency == null) return true;
    return widget.currency.toUpperCase() == methodCurrency.toUpperCase();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _paymentMethodsRepository.getPaymentMethods();
      final List<_PaymentMethodCategory> categories = [];

      for (final paymentMethod in response.data) {
        final List<_SelectablePaymentMethod> methods = [];

        for (final item in paymentMethod.paymentMethodItemResponses) {
          if (item.hasVariants) {
            final matchingVariants = item.paymentMethodItemResponses
                .where((v) => _currencyMatches(v.currency))
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
              ),
            );
          } else {
            if (!_currencyMatches(item.currency)) continue;
            methods.add(
              _SelectablePaymentMethod(
                id: item.itemCode,
                displayName: item.displayName,
                iconUrl: item.iconUrl,
                variantCode: item.itemCode,
                currency: item.currency,
                hasVariants: false,
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
          _errorMessage = 'Failed to load payment methods.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load payment methods. Please try again.'),
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
                leading: v.iconUrl.isNotEmpty
                    ? Image.network(v.iconUrl, width: 40, height: 40, fit: BoxFit.contain)
                    : const Icon(Icons.payment),
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
        const SnackBar(
          content: Text('Please select a payment option.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final categoryName = _getCategoryNameForSelectedMethod();
    final variantDisplayName = _getSelectedVariantDisplayName();
    final methodType = getPaymentMethodType(
      categoryName,
      method.displayName,
      variantDisplayName,
    );
    final waafiPrefix = getWaafiPrefix(
      categoryName,
      method.displayName,
      variantDisplayName,
    );

    String? paymentAccount;
    if (requiresMethodSpecificPhone(methodType)) {
      final digits = _methodSpecificDigitsController.text.trim();
      final digitsValid =
          digits.length == 7 && RegExp(r'^\d{7}$').hasMatch(digits);
      if (methodType == PaymentMethodType.waafi &&
          waafiPrefix != null &&
          digitsValid) {
        paymentAccount = waafiPrefix + digits;
      } else if (methodType == PaymentMethodType.edahab && digitsValid) {
        paymentAccount = '65$digits';
      } else if (methodType == PaymentMethodType.ipay &&
          _ipayPhoneNumber != null &&
          _ipayPhoneNumber!.isNotEmpty) {
        paymentAccount =
            _ipayPhoneNumber!.replaceAll(RegExp(r'[^\d]'), '');
        if (paymentAccount.isEmpty) paymentAccount = null;
      }
      if (paymentAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid phone number for payment.'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    }

    setState(() => _errorMessage = null);
    try {
      final request = PaymentRetryRequest(
        paymentReference: widget.paymentReference,
        paymentProviderCode: method.id,
        paymentProviderVariantCode: variantCode,
        paymentAccount: paymentAccount,
      );
      final updated = await _checkoutRepository.retryPayment(request);
      if (!mounted) return;

      final paymentUrl = updated.paymentInitiation?.paymentUrl;
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
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
        String msg = 'Failed to retry payment. Please try again.';
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
  }

  @override
  void dispose() {
    _methodSpecificDigitsController.dispose();
    super.dispose();
  }

  String? _getCategoryNameForSelectedMethod() {
    if (_selectedPaymentMethodId == null) return null;
    for (final cat in _categories) {
      if (cat.methods.any((m) => m.id == _selectedPaymentMethodId)) {
        return cat.categoryName;
      }
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

  @override
  Widget build(BuildContext context) {
    final title = widget.orderNumber != null
        ? 'Pay order ${widget.orderNumber}'
        : 'Choose payment method';

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
    final requiresMethodPhone = selectedMethod != null &&
        requiresMethodSpecificPhone(methodType);
    final digits = _methodSpecificDigitsController.text.trim();
    final digitsValid =
        digits.length == 7 && RegExp(r'^\d{7}$').hasMatch(digits);
    final methodPhoneValid = !requiresMethodPhone ||
        (methodType == PaymentMethodType.waafi && waafiPrefix != null && digitsValid) ||
        (methodType == PaymentMethodType.edahab && digitsValid) ||
        (methodType == PaymentMethodType.ipay &&
            _ipayPhoneNumber != null &&
            _ipayPhoneNumber!.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Text(
                      _errorMessage ?? 'No payment methods available.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(Spacing.md),
                        children: [
                          Text(
                            'Select a payment method to retry',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                          const SizedBox(height: Spacing.md),
                          ..._categories.map((category) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: Spacing.xs,
                                    top: Spacing.sm,
                                  ),
                                  child: Text(
                                    category.categoryName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
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
                                      isSelected:
                                          _selectedPaymentMethodId == method.id,
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
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    if (requiresMethodPhone)
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                            Spacing.md, Spacing.sm, Spacing.md, Spacing.md),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone number for payment',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                            ),
                            const SizedBox(height: Spacing.sm),
                            if (methodType == PaymentMethodType.waafi &&
                                waafiPrefix != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      '+$waafiPrefix ',
                                      style:
                                          Theme.of(context).textTheme.titleMedium,
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
                                          borderSide:
                                              BorderSide(color: Colors.grey[300]!),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: Spacing.md,
                                                vertical: Spacing.md),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
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
                                          borderSide:
                                              BorderSide(color: Colors.grey[300]!),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: Spacing.md,
                                                vertical: Spacing.md),
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
                                    _ipayPhoneNumber =
                                        phone.completeNumber.isNotEmpty
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
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: Spacing.md,
                                      vertical: Spacing.md),
                                ),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                          ],
                        ),
                      ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: (_getSelectedMethod() == null ||
                                    (requiresMethodPhone && !methodPhoneValid))
                                ? null
                                : _payWithSelectedMethod,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.md,
                              ),
                            ),
                            child: const Text('Pay with this method'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
