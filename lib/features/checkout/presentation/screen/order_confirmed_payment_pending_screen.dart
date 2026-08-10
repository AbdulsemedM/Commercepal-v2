import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../services/localization_service.dart';
import '../../bloc/payment_status_cubit.dart';
import '../../data/models/checkout_response.dart';
import '../../data/models/payment_initiate_result.dart';
import '../widgets/payment_status_polling_banner.dart';

/// Shown after checkout when payment is initiated but not yet completed.
class OrderConfirmedPaymentPendingScreen extends StatelessWidget {
  const OrderConfirmedPaymentPendingScreen({
    super.key,
    required this.response,
    this.initiateResult,
    this.paymentProviderCode,
  });

  final CheckoutResponse response;
  final PaymentInitiateResult? initiateResult;
  final String? paymentProviderCode;

  static const Color _pendingTint = Color(0xFFFFF8E1);
  static const Color _pendingBorder = Color(0xFFFFE082);

  @override
  Widget build(BuildContext context) {
    final String orderNum = response.resolvedOrderNumber ?? '';
    return BlocProvider(
      create: (_) => PaymentStatusCubit(),
      child: _OrderConfirmedPaymentPendingBody(
        response: response,
        initiateResult: initiateResult,
        orderNumber: orderNum,
        paymentProviderCode: paymentProviderCode,
      ),
    );
  }
}

class _OrderConfirmedPaymentPendingBody extends StatefulWidget {
  const _OrderConfirmedPaymentPendingBody({
    required this.response,
    required this.initiateResult,
    required this.orderNumber,
    this.paymentProviderCode,
  });

  final CheckoutResponse response;
  final PaymentInitiateResult? initiateResult;
  final String orderNumber;
  final String? paymentProviderCode;

  @override
  State<_OrderConfirmedPaymentPendingBody> createState() =>
      _OrderConfirmedPaymentPendingBodyState();
}

class _OrderConfirmedPaymentPendingBodyState
    extends State<_OrderConfirmedPaymentPendingBody>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (widget.orderNumber.isEmpty || !mounted) return;
    context.read<PaymentStatusCubit>().checkNow();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final summary = widget.response.pricingSummary;
    final currency =
        (summary?.currency ?? widget.response.currency ?? '').trim().isNotEmpty
            ? (summary?.currency ?? widget.response.currency)!.trim()
            : 'ETB';
    final subtotal = summary?.subtotal;
    final total = widget.response.resolvedTotalAmount ??
        summary?.totalAmount ??
        subtotal;
    final checkoutInstructions =
        widget.response.paymentInitiation?.resolvedInstructions ?? '';
    final initiateInstructions =
        widget.initiateResult?.paymentInstructions?.trim() ?? '';
    final instructions = initiateInstructions.isNotEmpty
        ? initiateInstructions
        : checkoutInstructions;
    final pending =
        (widget.response.paymentStatus ?? '').toUpperCase() == 'PENDING';
    final paymentRef = widget.initiateResult?.resolvedReference ??
        widget.response.paymentInitiation?.paymentReference?.trim() ??
        '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        context.go(AppRoutes.dashboard);
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xl,
              vertical: Spacing.lg,
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: Spacing.md),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: OrderConfirmedPaymentPendingScreen._pendingTint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: OrderConfirmedPaymentPendingScreen._pendingBorder,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 40,
                    color: AppColors.warning.withValues(alpha: 0.95),
                  ),
                ),
              const SizedBox(height: Spacing.lg),
              Text(
                LocalizationService.t(context, 'checkout.paymentPendingTitle'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                LocalizationService.t(
                  context,
                  'checkout.paymentPendingSubtitle',
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              if (widget.orderNumber.isNotEmpty) ...[
                PaymentStatusPollingBanner(
                  orderNumber: widget.orderNumber,
                  clearCartOnSuccess: true,
                  onSuccess: () => navigateOnPaymentStatusSuccess(context),
                ),
                const SizedBox(height: Spacing.lg),
              ],
              if (pending) _PaymentPendingBanner(theme: theme, scheme: scheme),
              if (pending) const SizedBox(height: Spacing.lg),
              if ((widget.initiateResult?.ussdCode != null &&
                      widget.initiateResult!.ussdCode!.isNotEmpty) ||
                  (widget.response.ussdCode != null &&
                      widget.response.ussdCode!.trim().isNotEmpty)) ...[
                _UssdCard(
                  theme: theme,
                  scheme: scheme,
                  ussdCode: widget.initiateResult?.ussdCode?.trim().isNotEmpty ==
                          true
                      ? widget.initiateResult!.ussdCode!
                      : widget.response.ussdCode!.trim(),
                  reference: widget.initiateResult?.resolvedReference,
                ),
                const SizedBox(height: Spacing.lg),
              ],
              _OrderSummaryCard(
                theme: theme,
                scheme: scheme,
                orderNumber: widget.orderNumber,
                subtotal: subtotal,
                total: total,
                currency: currency,
                showInitiatedBadge: pending,
                paymentReference: paymentRef,
              ),
              if (widget.initiateResult?.message != null &&
                  widget.initiateResult!.message!.isNotEmpty) ...[
                const SizedBox(height: Spacing.lg),
                _InstructionsCard(
                  theme: theme,
                  scheme: scheme,
                  instructions: widget.initiateResult!.message!,
                  titleKey: 'checkout.edahabInitiateTitle',
                ),
              ],
              if (instructions.isNotEmpty) ...[
                const SizedBox(height: Spacing.lg),
                _InstructionsCard(
                  theme: theme,
                  scheme: scheme,
                  instructions: instructions,
                  titleKey: 'checkout.howToCompletePayment',
                ),
              ],
              const SizedBox(height: Spacing.xxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.orderHistory),
                  icon: const Icon(Icons.receipt_long_outlined, size: 20),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    LocalizationService.t(
                      context,
                      'checkout.viewOrderHistory',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    LocalizationService.t(
                      context,
                      'checkout.continueShopping',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: LocalizationService.t(
                        context,
                        'checkout.orderConfirmedHelpPrefix',
                      ),
                    ),
                    TextSpan(
                      text: widget.orderNumber,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _UssdCard extends StatelessWidget {
  const _UssdCard({
    required this.theme,
    required this.scheme,
    required this.ussdCode,
    this.reference,
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final String ussdCode;
  final String? reference;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            LocalizationService.t(context, 'checkout.telebirrUssdTitle'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  ussdCode,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                tooltip: LocalizationService.t(context, 'checkout.copyUssd'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: ussdCode));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        LocalizationService.t(context, 'checkout.ussdCopied'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
              ),
              IconButton(
                tooltip: 'Open dialer',
                onPressed: () async {
                  final Uri uri =
                      Uri.parse('tel:${Uri.encodeComponent(ussdCode)}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.phone_outlined),
              ),
            ],
          ),
          if (reference != null && reference!.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              LocalizationService.t(context, 'checkout.reference'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              reference!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentPendingBanner extends StatelessWidget {
  const _PaymentPendingBanner({required this.theme, required this.scheme});

  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final Color bannerBg = scheme.brightness == Brightness.dark
        ? AppColors.warning.withValues(alpha: 0.18)
        : OrderConfirmedPaymentPendingScreen._pendingTint;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: OrderConfirmedPaymentPendingScreen._pendingBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  LocalizationService.t(
                    context,
                    'checkout.paymentPendingBannerTitle',
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  LocalizationService.t(
                    context,
                    'checkout.paymentPendingBannerBody',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.theme,
    required this.scheme,
    required this.orderNumber,
    required this.subtotal,
    required this.total,
    required this.currency,
    required this.showInitiatedBadge,
    this.paymentReference = '',
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final String orderNumber;
  final num? subtotal;
  final num? total;
  final String currency;
  final bool showInitiatedBadge;
  final String paymentReference;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      LocalizationService.t(context, 'checkout.orderNumberLabel'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            orderNumber.isEmpty ? '—' : orderNumber,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (orderNumber.isNotEmpty)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: LocalizationService.t(
                              context,
                              'checkout.copyOrderNumber',
                            ),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: orderNumber),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocalizationService.t(
                                      context,
                                      'checkout.orderNumberCopied',
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_outlined, size: 20),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showInitiatedBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.brightness == Brightness.dark
                        ? AppColors.warning.withValues(alpha: 0.2)
                        : OrderConfirmedPaymentPendingScreen._pendingTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        LocalizationService.t(
                          context,
                          'checkout.statusPending',
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (paymentReference.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              LocalizationService.t(context, 'checkout.reference'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              paymentReference,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          Divider(height: Spacing.xl, color: scheme.outlineVariant),
          if (subtotal != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  LocalizationService.t(context, 'checkout.subtotal'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  MoneyFormatter.format(subtotal!, currency),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          if (subtotal != null) const SizedBox(height: Spacing.sm),
          Divider(height: Spacing.lg, color: scheme.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'checkout.totalDue'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                total != null
                    ? MoneyFormatter.format(total!, currency)
                    : '—',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({
    required this.theme,
    required this.scheme,
    required this.instructions,
    required this.titleKey,
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final String instructions;
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            LocalizationService.t(context, titleKey),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            instructions,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
