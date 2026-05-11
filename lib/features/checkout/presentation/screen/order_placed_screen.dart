import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../services/invoice_pdf_service.dart';
import '../../../../services/localization_service.dart';
import '../../../orders/data/repository/orders_repository.dart';
import '../../data/models/checkout_response.dart';
import '../../data/models/payment_retry_request.dart';
import '../../data/repository/checkout_repository.dart';

/// Displays the checkout response from the backend after placing an order:
/// order number, pricing summary, payment status, payment initiation details.
/// When payment has failed (e.g. nextAction RETRY_PAYMENT), user can retry
/// via POST /api/v1/payments/retry.
class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({
    super.key,
    required this.response,
    this.paymentProviderCode = '',
  });

  final CheckoutResponse response;
  final String paymentProviderCode;

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  late CheckoutResponse _response;
  bool _isRetrying = false;
  bool _isGeneratingInvoice = false;
  final CheckoutRepository _checkoutRepository = CheckoutRepository();
  final OrdersRepository _ordersRepository = OrdersRepository();

  @override
  void initState() {
    super.initState();
    _response = widget.response;
  }

  static String? _formatOrderedAt(String? orderedAt) {
    if (orderedAt == null || orderedAt.isEmpty) return null;
    try {
      final dt = DateTime.tryParse(orderedAt);
      if (dt == null) return orderedAt;
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return orderedAt;
    }
  }

  Future<void> _retryPayment() async {
    final initiation = _response.paymentInitiation;
    final ref = initiation?.paymentReference;
    if (ref == null ||
        ref.isEmpty ||
        widget.paymentProviderCode.isEmpty) return;

    setState(() => _isRetrying = true);
    try {
      final request = PaymentRetryRequest(
        paymentReference: ref,
        paymentProviderCode: widget.paymentProviderCode,
      );
      final updated = await _checkoutRepository.retryPayment(request);
      if (!mounted) return;
      setState(() {
        _response = updated;
        _isRetrying = false;
      });
      final newUrl = updated.paymentInitiation?.paymentUrl;
      if (newUrl != null && newUrl.isNotEmpty) {
        context.push(
          AppRoutes.paymentWebView,
          extra: <String, dynamic>{
            'paymentUrl': newUrl,
            'orderNumber': updated.orderNumber,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.t(context, 'checkout.retryRequested')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRetrying = false);
        String msg = LocalizationService.t(context, 'checkout.failedToRetryPayment');
        if (e is DioException && e.response?.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          final apiMessage = data['message'] as String?;
          if (apiMessage != null && apiMessage.isNotEmpty) msg = apiMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _downloadInvoice() async {
    final orderNumber = _response.orderNumber;
    if (orderNumber == null || orderNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(LocalizationService.t(context, 'checkout.orderNumberNotAvailable')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isGeneratingInvoice = true);
    try {
      final order = await _ordersRepository.getOrderByOrderNumber(orderNumber);
      final pdfBytes = await InvoicePdfService.buildPdf(
        order: order,
        paymentReference: _response.paymentInitiation?.paymentReference,
        paymentMethodName: widget.paymentProviderCode.isNotEmpty
            ? widget.paymentProviderCode
            : null,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice_$orderNumber.pdf');
      await file.writeAsBytes(pdfBytes);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice - Order $orderNumber',
        text: 'Your CommercePal invoice for order $orderNumber',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(LocalizationService.t(context, 'checkout.invoiceReady')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('404') || e.toString().contains('not found')
                  ? LocalizationService.t(context, 'checkout.orderDetailsNotAvailable')
                  : LocalizationService.t(context, 'checkout.failedToGenerateInvoice'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingInvoice = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final response = _response;
    final pricing = response.pricingSummary;
    final initiation = response.paymentInitiation;
    final hasPaymentUrl = initiation?.paymentUrl != null &&
        (initiation?.paymentUrl?.isNotEmpty ?? false);
    final nextAction = initiation?.nextAction;
    final paymentInstructions = initiation?.paymentInstructions;
    final paymentReference = initiation?.paymentReference;
    final orderedAtFormatted = _formatOrderedAt(response.orderedAt);
    final canRetry = (initiation?.success == false ||
            nextAction == 'RETRY_PAYMENT') &&
        paymentReference != null &&
        paymentReference.isNotEmpty &&
        widget.paymentProviderCode.isNotEmpty;

    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(LocalizationService.t(context, 'checkout.orderPlaced')),
        backgroundColor: scheme.surface,
        iconTheme: IconThemeData(color: scheme.onSurface),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order number & status
            Card(
              elevation: 0,
              color: scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (response.orderNumber != null) ...[
                      Text(
                        response.orderNumber!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: Spacing.xs),
                    ],
                    if (response.paymentStatus != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: response.paymentStatus!
                                      .toUpperCase()
                                      .contains('PENDING')
                                  ? AppColors.warning.withValues(alpha: 0.2)
                                  : AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              response.paymentStatus!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    if (orderedAtFormatted != null) ...[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        orderedAtFormatted,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Pricing summary
            if (pricing != null) ...[
              Text(
                LocalizationService.t(context, 'checkout.orderSummary'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: Spacing.xs),
              Card(
                elevation: 0,
                color: AppColors.lightGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    children: [
                      if (pricing.subtotal != null)
                        _row(
                          context,
                          LocalizationService.t(context, 'checkout.subtotal'),
                          _formatMoney(pricing.subtotal!, pricing.currency),
                        ),
                      if (pricing.discountAmount != null &&
                          (pricing.discountAmount ?? 0) > 0)
                        _row(
                          context,
                          LocalizationService.t(context, 'checkout.discount'),
                          '-${_formatMoney(pricing.discountAmount!, pricing.currency)}',
                        ),
                      if (pricing.deliveryFee != null &&
                          (pricing.deliveryFee ?? 0) > 0)
                        _row(
                          context,
                          LocalizationService.t(context, 'checkout.delivery'),
                          _formatMoney(pricing.deliveryFee!, pricing.currency),
                        ),
                      if (pricing.additionalCharges != null &&
                          (pricing.additionalCharges ?? 0) > 0)
                        _row(
                          context,
                          LocalizationService.t(context, 'checkout.additionalCharges'),
                          _formatMoney(
                            pricing.additionalCharges!,
                            pricing.currency,
                          ),
                        ),
                      if (pricing.totalAmount != null) ...[
                        const Divider(height: Spacing.md),
                        _row(
                          context,
                          LocalizationService.t(context, 'checkout.total'),
                          _formatMoney(pricing.totalAmount!, pricing.currency),
                          isTotal: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],

            // Payment initiation (reference, instructions, next action)
            if (paymentReference != null ||
                (paymentInstructions != null &&
                    paymentInstructions.isNotEmpty) ||
                nextAction != null) ...[
              Text(
                LocalizationService.t(context, 'checkout.payment'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: Spacing.xs),
              Card(
                elevation: 0,
                color: AppColors.lightGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (paymentReference != null &&
                          paymentReference.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  LocalizationService.t(context, 'checkout.reference'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  paymentReference,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (paymentInstructions != null &&
                          paymentInstructions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: Text(
                            paymentInstructions,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      if (nextAction != null && nextAction.isNotEmpty)
                        Text(
                          '${LocalizationService.t(context, 'checkout.next')}: $nextAction',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],

            // Actions
            if (hasPaymentUrl)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: FilledButton.icon(
                  onPressed: () {
                    context.push(
                      AppRoutes.paymentWebView,
                      extra: <String, dynamic>{
                        'paymentUrl': initiation?.paymentUrl ?? '',
                        'orderNumber': response.orderNumber,
                      },
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: Text(LocalizationService.t(context, 'checkout.completePayment')),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  ),
                ),
              ),
            if (canRetry) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: FilledButton.icon(
                  onPressed: _isRetrying ? null : _retryPayment,
                  icon: _isRetrying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isRetrying ? LocalizationService.t(context, 'checkout.retrying') : LocalizationService.t(context, 'checkout.retryPayment')),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await context.push<CheckoutResponse?>(
                      AppRoutes.retryPaymentMethod,
                      extra: <String, dynamic>{
                        'paymentReference': paymentReference,
                        'currency': response.currency ?? '',
                        'orderNumber': response.orderNumber,
                      },
                    );
                    if (result != null && mounted) {
                      setState(() => _response = result);
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: Text(LocalizationService.t(context, 'checkout.chooseAnotherPaymentMethod')),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: OutlinedButton.icon(
                onPressed: _isGeneratingInvoice ? null : _downloadInvoice,
                icon: _isGeneratingInvoice
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isGeneratingInvoice
                      ? LocalizationService.t(context, 'checkout.generating')
                      : LocalizationService.t(context, 'checkout.downloadInvoicePdf'),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: Text(LocalizationService.t(context, 'checkout.backToHome')),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.w600 : null,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : null,
                ),
          ),
        ],
      ),
    );
  }

  static String _formatMoney(num amount, String? currency) {
    final code = currency ?? '';
    return MoneyFormatter.format(amount, code);
  }
}
