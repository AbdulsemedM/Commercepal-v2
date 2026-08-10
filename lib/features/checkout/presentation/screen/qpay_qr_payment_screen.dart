import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../services/localization_service.dart';
import '../../../orders/data/repository/orders_repository.dart';
import '../../data/models/checkout_response.dart';
import '../widgets/qr_code_display.dart';

/// Shown after checkout when nextAction is `SCAN_QR` or `SHOW_QR_CODE`
/// (e.g. QPay bank-app QR payments).
class QpayQrPaymentScreen extends StatefulWidget {
  const QpayQrPaymentScreen({
    super.key,
    required this.response,
  });

  final CheckoutResponse response;

  @override
  State<QpayQrPaymentScreen> createState() => _QpayQrPaymentScreenState();
}

class _QpayQrPaymentScreenState extends State<QpayQrPaymentScreen> {
  static const int _pollMaxAttempts = 40;
  static const Duration _pollInterval = Duration(seconds: 15);
  static const Duration _qrExpiry = Duration(minutes: 5);

  final OrdersRepository _ordersRepository = OrdersRepository();
  Timer? _countdownTimer;
  Timer? _pollTimer;
  Duration _remaining = _qrExpiry;
  int _pollAttempt = 0;
  bool _paymentConfirmed = false;
  String? _pollStatusMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startPaymentPolling();
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
        final order =
            await _ordersRepository.getOrderByOrderNumber(orderNumber);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
    final total = summary?.totalAmount ?? summary?.subtotal;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.lg,
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      LocalizationService.t(
                        context,
                        'checkout.scanToPayWithQpay',
                      ),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A2744),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.lg),
                    QrCodeDisplay(data: qrPayload, size: 220),
                    const SizedBox(height: Spacing.md),
                    Text(
                      LocalizationService.t(
                        context,
                        'checkout.openBankAppScanQr',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.lg),
                    Text(
                      _formatCountdown(_remaining),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      _paymentConfirmed
                          ? (_pollStatusMessage ??
                              LocalizationService.t(
                                context,
                                'checkout.paymentConfirmed',
                              ))
                          : LocalizationService.t(
                              context,
                              'checkout.waitingForPaymentConfirmation',
                            ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _paymentConfirmed
                            ? AppColors.success
                            : scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DetailRow(
                      label: LocalizationService.t(context, 'checkout.order'),
                      value: orderNumber.isEmpty ? '—' : orderNumber,
                    ),
                    const SizedBox(height: Spacing.sm),
                    _DetailRow(
                      label: LocalizationService.t(context, 'checkout.total'),
                      value: total != null
                          ? MoneyFormatter.format(total, currency)
                          : '—',
                      valueStyle: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    _DetailRow(
                      label: LocalizationService.t(
                        context,
                        'checkout.payment',
                      ),
                      value: providerCode,
                    ),
                  ],
                ),
              ),
              if (!_paymentConfirmed && _pollAttempt > 0) ...[
                const SizedBox(height: Spacing.lg),
                Text(
                  LocalizationService.t(
                    context,
                    'checkout.checkingPaymentStatus',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: Spacing.xxl),
              if (_paymentConfirmed)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go(AppRoutes.orderHistory),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      LocalizationService.t(context, 'checkout.myOrders'),
                    ),
                  ),
                )
              else
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.orderHistory),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB45309),
                          side: const BorderSide(color: AppColors.secondary),
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          LocalizationService.t(context, 'checkout.myOrders'),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.go(AppRoutes.dashboard),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: Text(
                          LocalizationService.t(
                            context,
                            'checkout.continueShopping',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
