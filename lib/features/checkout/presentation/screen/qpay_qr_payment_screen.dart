import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/country_currency_constants.dart';
import '../../../../core/design_system.dart';
import '../../../../core/widgets/checkout_screen_header.dart';
import '../../../../services/localization_service.dart';
import '../../../orders/data/repository/orders_repository.dart';
import '../../data/models/checkout_response.dart';
import '../utils/qr_image_capture.dart';
import '../widgets/qr_code_display.dart';

/// Shown after checkout when nextAction is `SCAN_QR` or `SHOW_QR_CODE`
/// (e.g. QPay bank-app QR payments).
class QpayQrPaymentScreen extends StatefulWidget {
  const QpayQrPaymentScreen({
    super.key,
    required this.response,
    @visibleForTesting this.initialPaymentConfirmed = false,
    @visibleForTesting this.disablePaymentPolling = false,
  });

  final CheckoutResponse response;

  /// When true, renders the post-payment UI without waiting for polling.
  @visibleForTesting
  final bool initialPaymentConfirmed;

  /// Skips countdown and order polling (for widget tests).
  @visibleForTesting
  final bool disablePaymentPolling;

  @override
  State<QpayQrPaymentScreen> createState() => _QpayQrPaymentScreenState();
}

class _QpayQrPaymentScreenState extends State<QpayQrPaymentScreen> {
  static const int _pollMaxAttempts = 40;
  static const Duration _pollInterval = Duration(seconds: 15);
  static const Duration _qrExpiry = Duration(minutes: 5);
  static const double _qrDisplaySize = 260;

  OrdersRepository? _ordersRepository;
  final GlobalKey _qrCaptureKey = GlobalKey();
  Timer? _countdownTimer;
  Timer? _pollTimer;
  Duration _remaining = _qrExpiry;
  int _pollAttempt = 0;
  bool _paymentConfirmed = false;
  bool _isSavingQr = false;
  String? _pollStatusMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialPaymentConfirmed) {
      // Message falls back to the localized "payment confirmed" at build.
      _paymentConfirmed = true;
    } else if (!widget.disablePaymentPolling) {
      _startCountdown();
      _startPaymentPolling();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds <= 0) {
          _remaining = Duration.zero;
          _countdownTimer?.cancel();
        } else {
          _remaining -= const Duration(seconds: 1);
        }
      });
    });
  }

  void _startPaymentPolling() {
    final orderNumber = widget.response.resolvedOrderNumber;
    if (orderNumber == null || orderNumber.isEmpty) return;

    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (!mounted || _paymentConfirmed) return;
      if (_pollAttempt >= _pollMaxAttempts) {
        _pollTimer?.cancel();
        return;
      }

      setState(() => _pollAttempt++);

      try {
        final order = await (_ordersRepository ??= OrdersRepository())
            .getOrderByOrderNumber(orderNumber);
        if (!mounted) return;

        final status = order.paymentStatus.toUpperCase();
        if (status != 'PENDING' && status != 'UNPAID') {
          setState(() {
            _paymentConfirmed = true;
            _pollStatusMessage = order.paymentStatusLabel.isNotEmpty
                ? order.paymentStatusLabel
                : status;
          });
          _pollTimer?.cancel();
          _countdownTimer?.cancel();
        }
      } catch (_) {
        // Keep polling — transient network errors are expected.
      }
    });
  }

  String _formatCountdown(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveQrToGallery() async {
    if (_isSavingQr || _paymentConfirmed) return;

    setState(() => _isSavingQr = true);
    try {
      await captureAndSaveQrToGallery(boundaryKey: _qrCaptureKey);
      if (!mounted) return;
      AppSnackbars.success(context, context.tr('checkout.qrSavedToGallery'));
    } catch (_) {
      if (!mounted) return;
      AppSnackbars.error(context, context.tr('checkout.qrSaveFailed'));
    } finally {
      if (mounted) {
        setState(() => _isSavingQr = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final initiation = widget.response.paymentInitiation;
    final orderNumber = widget.response.resolvedOrderNumber ?? '';
    final qrPayload = widget.response.resolvedQrPayload ?? '';
    final providerCode =
        initiation?.paymentProviderCode?.trim().toUpperCase() ?? 'QPAY';
    final summary = widget.response.pricingSummary;
    final currency =
        (summary?.currency ?? widget.response.currency ?? '').trim().isNotEmpty
            ? (summary?.currency ?? widget.response.currency)!.trim()
            : 'ETB';
    final total = widget.response.resolvedTotalAmount ?? summary?.subtotal;
    final bool expired = !_paymentConfirmed && _remaining == Duration.zero;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CheckoutScreenHeader(
              title: context.tr('checkout.qpay.title'),
              showBack: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.gutter,
                  Spacing.xs,
                  Spacing.gutter,
                  Spacing.lg,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _AmountHeader(
                          total: total,
                          currency: currency,
                          orderNumber: orderNumber,
                          providerCode: providerCode,
                        ),
                        const SizedBox(height: Spacing.md),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.md),
                            child: Column(
                              children: <Widget>[
                                RepaintBoundary(
                                  key: _qrCaptureKey,
                                  child: QrCodeDisplay(
                                    data: qrPayload,
                                    size: _qrDisplaySize,
                                  ),
                                ),
                                if (!_paymentConfirmed) ...[
                                  const SizedBox(height: Spacing.md),
                                  _ExpiryIndicator(
                                    remaining: _remaining,
                                    total: _qrExpiry,
                                    label: expired
                                        ? context.tr('checkout.qpay.expired')
                                        : context.tr(
                                            'checkout.qpay.expiresIn',
                                            <String, Object?>{
                                              'time':
                                                  _formatCountdown(_remaining),
                                            },
                                          ),
                                    expired: expired,
                                  ),
                                  const SizedBox(height: Spacing.md),
                                  AppButton.secondary(
                                    key: const Key('qpay_save_qr_button'),
                                    label:
                                        context.tr('checkout.saveQrToGallery'),
                                    icon: Icons.download_rounded,
                                    size: AppButtonSize.medium,
                                    loading: _isSavingQr,
                                    onPressed:
                                        _isSavingQr ? null : _saveQrToGallery,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        _PaymentStatusLine(
                          confirmed: _paymentConfirmed,
                          title: _paymentConfirmed
                              ? (_pollStatusMessage ??
                                  context.tr('checkout.paymentConfirmed'))
                              : context.tr(
                                  'checkout.waitingForPaymentConfirmation',
                                ),
                          body: !_paymentConfirmed && _pollAttempt > 0
                              ? context.tr('checkout.checkingPaymentStatus')
                              : null,
                        ),
                        if (!_paymentConfirmed) ...[
                          const SizedBox(height: Spacing.md),
                          _InstructionSteps(
                            title: context.tr('checkout.qpay.howToPay'),
                            steps: <String>[
                              context.tr('checkout.qpay.step1'),
                              context.tr('checkout.qpay.step2'),
                              context.tr('checkout.qpay.step3'),
                              context.tr('checkout.qpay.step4'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: _paymentConfirmed
                        ? AppButton.primary(
                            label: context.tr('checkout.myOrders'),
                            icon: Icons.receipt_long_outlined,
                            onPressed: () => context.go(AppRoutes.orderHistory),
                          )
                        : Row(
                            children: <Widget>[
                              Expanded(
                                child: AppButton.secondary(
                                  label: context.tr('checkout.myOrders'),
                                  onPressed: () =>
                                      context.go(AppRoutes.orderHistory),
                                ),
                              ),
                              const SizedBox(width: Spacing.sm),
                              Expanded(
                                child: AppButton.primary(
                                  label:
                                      context.tr('checkout.continueShopping'),
                                  onPressed: () =>
                                      context.go(AppRoutes.dashboard),
                                ),
                              ),
                            ],
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

/// Amount to pay, order number and provider, shown above the QR.
class _AmountHeader extends StatelessWidget {
  const _AmountHeader({
    required this.total,
    required this.currency,
    required this.orderNumber,
    required this.providerCode,
  });

  final num? total;
  final String currency;
  final String orderNumber;
  final String providerCode;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle? caption = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Column(
      children: <Widget>[
        Text(
          context.tr('checkout.qpay.amountToPay'),
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.xxs),
        if (total != null)
          PriceTag(
            amount: total!,
            currency: CountryCurrencyConstants.getCurrencySymbol(currency),
            size: PriceTagSize.large,
          )
        else
          Text('—', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.xs),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.xs,
          runSpacing: Spacing.xxs,
          children: <Widget>[
            Text(context.tr('checkout.order'), style: caption),
            SelectableText(
              orderNumber.isEmpty ? '—' : orderNumber,
              style: caption?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppBadge(label: providerCode, tone: AppBadgeTone.neutral),
          ],
        ),
      ],
    );
  }
}

/// Countdown text with a thin bar showing how much validity is left.
class _ExpiryIndicator extends StatelessWidget {
  const _ExpiryIndicator({
    required this.remaining,
    required this.total,
    required this.label,
    required this.expired,
  });

  final Duration remaining;
  final Duration total;
  final String label;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    final double fraction = total.inSeconds <= 0
        ? 0
        : (remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);
    // Amber in the last minute so the shopper knows to hurry.
    final Color accent = expired
        ? scheme.error
        : remaining.inSeconds <= 60
            ? commerce.warning
            : scheme.primary;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              expired ? Icons.timer_off_outlined : Icons.timer_outlined,
              size: AppSizes.iconSm,
              color: accent,
            ),
            const SizedBox(width: Spacing.xxs),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: expired ? scheme.error : scheme.onSurface,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4,
              color: accent,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ),
      ],
    );
  }
}

/// Live status line: waiting (info tone) or confirmed (success tone).
class _PaymentStatusLine extends StatelessWidget {
  const _PaymentStatusLine({
    required this.confirmed,
    required this.title,
    this.body,
  });

  final bool confirmed;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommerceColors commerce = context.commerce;
    final Color accent = confirmed ? commerce.success : commerce.info;
    final Color container =
        confirmed ? commerce.successContainer : commerce.infoContainer;
    final Color onContainer =
        confirmed ? commerce.onSuccessContainer : commerce.onInfoContainer;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: container,
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              confirmed
                  ? Icons.check_circle_outline_rounded
                  : Icons.schedule_rounded,
              color: accent,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onContainer,
                    ),
                  ),
                  if (body != null) ...[
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      body!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Numbered how-to-pay steps.
class _InstructionSteps extends StatelessWidget {
  const _InstructionSteps({required this.title, required this.steps});

  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleSmall),
            ),
            const SizedBox(height: Spacing.sm),
            for (int i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(height: Spacing.sm),
              MergeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
