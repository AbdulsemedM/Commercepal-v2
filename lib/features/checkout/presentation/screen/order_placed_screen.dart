import 'dart:io';

import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_router.dart';
import '../../../../services/invoice_pdf_service.dart';
import '../../../../services/localization_service.dart';
import '../../../orders/data/repository/orders_repository.dart';
import '../../data/models/checkout_response.dart';
import '../../data/models/payment_flow_constants.dart';
import '../../data/models/payment_retry_request.dart';
import '../../data/repository/checkout_repository.dart';
import '../utils/payment_phone_utils.dart';
import '../utils/checkout_payment_navigation.dart';

/// Displays the checkout response from the backend after placing an order:
/// order number, pricing summary, payment status, payment initiation details.
/// When payment has failed (e.g. nextAction RETRY_PAYMENT), user can retry
/// via POST /api/payments/retry.
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

/// Visual tone of the hero / status badge, derived from the payment status.
enum _OrderTone { placed, success, pending, failed }

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
    final String? orderNumber = _response.resolvedOrderNumber;
    if (orderNumber == null ||
        orderNumber.isEmpty ||
        widget.paymentProviderCode.isEmpty) {
      return;
    }

    setState(() => _isRetrying = true);
    try {
      String? paymentAccount;
      final profilePhone = await loadDefaultPaymentPhone();
      if (profilePhone != null &&
          profilePhone.isNotEmpty &&
          isValidPaymentAccount(profilePhone)) {
        paymentAccount = normalizePaymentAccount(profilePhone);
      }

      final request = PaymentRetryRequest(
        paymentProviderCode: widget.paymentProviderCode,
        paymentAccount: paymentAccount,
      );
      final updated = await _checkoutRepository.retryPayment(
        orderNumber: orderNumber,
        request: request,
      );
      if (!mounted) return;
      setState(() {
        _response = updated;
        _isRetrying = false;
      });
      await navigateAfterRetryPaymentSuccess(
        context,
        updated,
        paymentProviderCode: widget.paymentProviderCode,
        paymentAccount: paymentAccount,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isRetrying = false);
        String msg = context.tr('checkout.failedToRetryPayment');
        if (e is DioException && e.response?.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          final apiMessage = data['message'] as String?;
          if (apiMessage != null && apiMessage.isNotEmpty) msg = apiMessage;
        }
        AppSnackbars.error(context, msg);
      }
    }
  }

  Future<void> _downloadInvoice() async {
    final orderNumber = _response.resolvedOrderNumber;
    if (orderNumber == null || orderNumber.isEmpty) {
      AppSnackbars.error(
          context, context.tr('checkout.orderNumberNotAvailable'));
      return;
    }
    final Map<String, Object?> shareArgs = <String, Object?>{
      'orderNumber': orderNumber,
    };
    final String shareSubject =
        context.tr('checkout.orderPlaced.invoiceShareSubject', shareArgs);
    final String shareText =
        context.tr('checkout.orderPlaced.invoiceShareText', shareArgs);
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
        subject: shareSubject,
        text: shareText,
      );
      if (mounted) {
        AppSnackbars.success(context, context.tr('checkout.invoiceReady'));
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.error(
          context,
          e.toString().contains('404') || e.toString().contains('not found')
              ? context.tr('checkout.orderDetailsNotAvailable')
              : context.tr('checkout.failedToGenerateInvoice'),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingInvoice = false);
    }
  }

  Future<void> _chooseAnotherPaymentMethod(String? paymentReference) async {
    final response = _response;
    final result = await context.push<CheckoutResponse?>(
      AppRoutes.retryPaymentMethod,
      extra: <String, dynamic>{
        'paymentReference': paymentReference,
        'currency': response.currency ?? '',
        'orderNumber': response.resolvedOrderNumber,
        'orderTotal': response.pricingSummary?.totalAmount?.toDouble(),
      },
    );
    if (result != null && mounted) {
      setState(() => _response = result);
    }
  }

  void _openPaymentUrl() {
    final response = _response;
    context.push(
      AppRoutes.paymentWebView,
      extra: <String, dynamic>{
        'paymentUrl': response.paymentInitiation?.paymentUrl ?? '',
        'orderNumber': response.resolvedOrderNumber,
      },
    );
  }

  static _OrderTone _toneFor(String status, String? nextAction) {
    if (status == PaymentStatus.failed ||
        status == PaymentStatus.cancelled ||
        nextAction == 'RETRY_PAYMENT') {
      return _OrderTone.failed;
    }
    if (status.contains(PaymentStatus.pending)) return _OrderTone.pending;
    if (status == PaymentStatus.success) return _OrderTone.success;
    return _OrderTone.placed;
  }

  String _statusLabel(BuildContext context, String rawStatus) {
    final String status = rawStatus.trim().toUpperCase();
    if (status.contains(PaymentStatus.pending)) {
      return context.tr('checkout.statusPending');
    }
    return switch (status) {
      PaymentStatus.success => context.tr('checkout.orderPlaced.statusPaid'),
      PaymentStatus.failed => context.tr('checkout.orderPlaced.statusFailed'),
      PaymentStatus.cancelled => context.tr('orderHistory.cancelled'),
      _ => rawStatus,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;

    final response = _response;
    final pricing = response.pricingSummary;
    final initiation = response.paymentInitiation;
    final hasPaymentUrl = initiation?.paymentUrl != null &&
        (initiation?.paymentUrl?.isNotEmpty ?? false);
    final nextAction = initiation?.nextAction;
    final paymentInstructions = initiation?.paymentInstructions;
    final paymentReference = initiation?.paymentReference;
    final orderedAtFormatted = _formatOrderedAt(response.orderedAt);
    final canRetry =
        (initiation?.success == false || nextAction == 'RETRY_PAYMENT') &&
            paymentReference != null &&
            paymentReference.isNotEmpty &&
            widget.paymentProviderCode.isNotEmpty;

    final String rawStatus = response.paymentStatus ?? '';
    final _OrderTone tone =
        _toneFor(rawStatus.trim().toUpperCase(), nextAction);

    final (IconData heroIcon, Color heroBg, Color heroFg) = switch (tone) {
      _OrderTone.failed => (
          Icons.error_outline_rounded,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
      _OrderTone.pending => (
          Icons.schedule_rounded,
          commerce.warningContainer,
          commerce.onWarningContainer,
        ),
      _ => (
          Icons.check_rounded,
          commerce.successContainer,
          commerce.success,
        ),
    };
    final (String heroTitle, String heroSubtitle) = switch (tone) {
      _OrderTone.failed => (
          context.tr('checkout.paymentStatusFailedTitle'),
          context.tr('checkout.paymentStatusFailedBody'),
        ),
      _OrderTone.pending => (
          context.tr('checkout.paymentPendingTitle'),
          context.tr('checkout.paymentInitiatedBody'),
        ),
      _OrderTone.success => (
          context.tr('checkout.orderConfirmedTitle'),
          context.tr('checkout.paymentStatusSuccessBody'),
        ),
      _OrderTone.placed => (
          context.tr('checkout.orderPlaced'),
          context.tr('checkout.orderPlaced.subtitle'),
        ),
    };
    final AppBadgeTone badgeTone = switch (tone) {
      _OrderTone.failed => AppBadgeTone.error,
      _OrderTone.pending => AppBadgeTone.warning,
      _OrderTone.success => AppBadgeTone.success,
      _OrderTone.placed => AppBadgeTone.neutral,
    };

    final String currency = pricing?.currency ?? '';
    final bool hasPaymentSection = paymentReference != null ||
        (paymentInstructions != null && paymentInstructions.isNotEmpty) ||
        nextAction != null;

    // The single most important action goes in the sticky bottom bar; the
    // rest live in the scrollable content.
    final bool primaryIsPay = hasPaymentUrl;
    final bool primaryIsRetry = !hasPaymentUrl && canRetry;
    final bool primaryIsHome = !primaryIsPay && !primaryIsRetry;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            CheckoutScreenHeader(
              title: context.tr('checkout.orderPlaced.confirmationTitle'),
              onBack: () => context.go(AppRoutes.dashboard),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  Spacing.gutter,
                  Spacing.xs,
                  Spacing.gutter,
                  Spacing.xl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Hero
                        const SizedBox(height: Spacing.md),
                        Center(
                          child: _StatusHalo(
                            icon: heroIcon,
                            background: heroBg,
                            foreground: heroFg,
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        Semantics(
                          header: true,
                          liveRegion: true,
                          child: Text(
                            heroTitle,
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          heroSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.xl),

                        // Order number, status, date, method
                        Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            context.tr(
                                              'checkout.orderPlaced.orderNumber',
                                            ),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: Spacing.xxs),
                                          SelectableText(
                                            response.resolvedOrderNumber ?? '—',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontFeatures:
                                                  AppTypography.tabularFigures,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (rawStatus.isNotEmpty) ...<Widget>[
                                      const SizedBox(width: Spacing.xs),
                                      Semantics(
                                        liveRegion: true,
                                        child: AppBadge(
                                          label:
                                              _statusLabel(context, rawStatus),
                                          tone: badgeTone,
                                          size: AppBadgeSize.medium,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (orderedAtFormatted != null ||
                                    widget.paymentProviderCode
                                        .isNotEmpty) ...<Widget>[
                                  const Divider(height: Spacing.xl),
                                  if (orderedAtFormatted != null)
                                    _DetailRow(
                                      label: context
                                          .tr('checkout.orderPlaced.orderedOn'),
                                      value: orderedAtFormatted,
                                    ),
                                  if (orderedAtFormatted != null &&
                                      widget.paymentProviderCode.isNotEmpty)
                                    const SizedBox(height: Spacing.xs),
                                  if (widget.paymentProviderCode.isNotEmpty)
                                    _DetailRow(
                                      label: context.tr(
                                        'checkout.orderPlaced.paymentMethod',
                                      ),
                                      value: widget.paymentProviderCode,
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Pricing summary
                        if (pricing != null) ...<Widget>[
                          const SizedBox(height: Spacing.md),
                          Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(Spacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      context.tr('checkout.orderSummary'),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.sm),
                                  if (pricing.subtotal != null)
                                    _DetailRow(
                                      label: context.tr('checkout.subtotal'),
                                      value: MoneyFormatter.format(
                                        pricing.subtotal!,
                                        currency,
                                      ),
                                      tabular: true,
                                    ),
                                  if (pricing.discountAmount != null &&
                                      (pricing.discountAmount ?? 0) > 0)
                                    _DetailRow(
                                      label: context.tr('checkout.discount'),
                                      value:
                                          '-${MoneyFormatter.format(pricing.discountAmount!, currency)}',
                                      tabular: true,
                                      valueColor: commerce.success,
                                    ),
                                  if (pricing.deliveryFee != null &&
                                      (pricing.deliveryFee ?? 0) > 0)
                                    _DetailRow(
                                      label: context.tr('checkout.delivery'),
                                      value: MoneyFormatter.format(
                                        pricing.deliveryFee!,
                                        currency,
                                      ),
                                      tabular: true,
                                    ),
                                  if (pricing.additionalCharges != null &&
                                      (pricing.additionalCharges ?? 0) > 0)
                                    _DetailRow(
                                      label: context
                                          .tr('checkout.additionalCharges'),
                                      value: MoneyFormatter.format(
                                        pricing.additionalCharges!,
                                        currency,
                                      ),
                                      tabular: true,
                                    ),
                                  if (pricing.totalAmount != null) ...<Widget>[
                                    const Divider(height: Spacing.lg),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            context.tr('checkout.total'),
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        PriceTag(
                                          amount: pricing.totalAmount!,
                                          currency: CountryCurrencyConstants
                                              .getCurrencySymbol(currency),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Payment initiation (reference, instructions, next)
                        if (hasPaymentSection) ...<Widget>[
                          const SizedBox(height: Spacing.md),
                          Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(Spacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      context.tr('checkout.payment'),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.sm),
                                  if (paymentReference != null &&
                                      paymentReference.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        bottom: Spacing.sm,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              context.tr('checkout.reference'),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: Spacing.sm),
                                          Flexible(
                                            flex: 2,
                                            child: SelectableText(
                                              paymentReference,
                                              textAlign: TextAlign.end,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontFeatures: AppTypography
                                                    .tabularFigures,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (paymentInstructions != null &&
                                      paymentInstructions.isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsetsDirectional.only(
                                        bottom: Spacing.sm,
                                      ),
                                      padding: const EdgeInsets.all(Spacing.sm),
                                      decoration: BoxDecoration(
                                        color: commerce.infoContainer,
                                        borderRadius: AppRadius.mdAll,
                                      ),
                                      child: Text(
                                        paymentInstructions,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: commerce.onInfoContainer,
                                        ),
                                      ),
                                    ),
                                  if (nextAction != null &&
                                      nextAction.isNotEmpty)
                                    Text(
                                      '${context.tr('checkout.next')}: $nextAction',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Secondary actions
                        const SizedBox(height: Spacing.lg),
                        if (canRetry && !primaryIsRetry) ...<Widget>[
                          AppButton.secondary(
                            label: context.tr('checkout.retryPayment'),
                            icon: Icons.refresh_rounded,
                            size: AppButtonSize.medium,
                            loading: _isRetrying,
                            onPressed: _retryPayment,
                          ),
                          const SizedBox(height: Spacing.sm),
                        ],
                        if (canRetry) ...<Widget>[
                          AppButton.secondary(
                            label: context
                                .tr('checkout.chooseAnotherPaymentMethod'),
                            icon: Icons.payment_outlined,
                            size: AppButtonSize.medium,
                            onPressed: () =>
                                _chooseAnotherPaymentMethod(paymentReference),
                          ),
                          const SizedBox(height: Spacing.sm),
                        ],
                        AppButton.tonal(
                          label: context.tr('checkout.downloadInvoicePdf'),
                          icon: Icons.download_rounded,
                          loading: _isGeneratingInvoice,
                          onPressed: _downloadInvoice,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _BottomActions(
              children: <Widget>[
                if (primaryIsPay)
                  AppButton.primary(
                    label: context.tr('checkout.completePayment'),
                    icon: Icons.payment_rounded,
                    onPressed: _openPaymentUrl,
                  ),
                if (primaryIsRetry)
                  AppButton.primary(
                    label: context.tr('checkout.retryPayment'),
                    icon: Icons.refresh_rounded,
                    loading: _isRetrying,
                    onPressed: _retryPayment,
                  ),
                if (primaryIsHome)
                  AppButton.primary(
                    label: context.tr('checkout.backToHome'),
                    onPressed: () => context.go(AppRoutes.dashboard),
                  )
                else
                  AppButton.secondary(
                    label: context.tr('checkout.backToHome'),
                    size: AppButtonSize.medium,
                    onPressed: () => context.go(AppRoutes.dashboard),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular tinted halo with a status icon.
class _StatusHalo extends StatelessWidget {
  const _StatusHalo({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 44, color: foreground),
      ),
    );
  }
}

/// Label on the start side, value on the end side.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.tabular = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool tabular;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? scheme.onSurface,
                fontFeatures: tabular ? AppTypography.tabularFigures : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky action area pinned above the system navigation bar.
class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: context.commerce.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                Spacing.gutter,
                Spacing.sm,
                Spacing.gutter,
                Spacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < children.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: Spacing.xs),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
