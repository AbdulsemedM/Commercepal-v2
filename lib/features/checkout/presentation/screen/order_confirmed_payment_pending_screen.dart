import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/country_currency_constants.dart';
import '../../../../core/design_system.dart';
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
    final CommerceColors commerce = context.commerce;
    final summary = widget.response.pricingSummary;
    final currency =
        (summary?.currency ?? widget.response.currency ?? '').trim().isNotEmpty
            ? (summary?.currency ?? widget.response.currency)!.trim()
            : 'ETB';
    final subtotal = summary?.subtotal;
    final total =
        widget.response.resolvedTotalAmount ?? summary?.totalAmount ?? subtotal;
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
    final bool hasUssd = (widget.initiateResult?.ussdCode != null &&
            widget.initiateResult!.ussdCode!.isNotEmpty) ||
        (widget.response.ussdCode != null &&
            widget.response.ussdCode!.trim().isNotEmpty);
    final String method = widget.paymentProviderCode?.trim() ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        context.go(AppRoutes.dashboard);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.gutter,
                    Spacing.xl,
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
                          Center(
                            child: ExcludeSemantics(
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: commerce.warningContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.hourglass_top_rounded,
                                  size: 44,
                                  color: commerce.warning,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          Semantics(
                            header: true,
                            child: Text(
                              context.tr('checkout.paymentPendingTitle'),
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            context.tr('checkout.paymentPendingSubtitle'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.xl),
                          if (widget.orderNumber.isNotEmpty) ...[
                            PaymentStatusPollingBanner(
                              orderNumber: widget.orderNumber,
                              clearCartOnSuccess: true,
                              onSuccess: () =>
                                  navigateOnPaymentStatusSuccess(context),
                            ),
                            const SizedBox(height: Spacing.sm),
                          ],
                          if (pending) ...[
                            const _PaymentPendingBanner(),
                            const SizedBox(height: Spacing.md),
                          ],
                          if (hasUssd) ...[
                            _UssdCard(
                              ussdCode: widget.initiateResult?.ussdCode
                                          ?.trim()
                                          .isNotEmpty ==
                                      true
                                  ? widget.initiateResult!.ussdCode!
                                  : widget.response.ussdCode!.trim(),
                              reference:
                                  widget.initiateResult?.resolvedReference,
                            ),
                            const SizedBox(height: Spacing.md),
                          ],
                          _OrderSummaryCard(
                            orderNumber: widget.orderNumber,
                            subtotal: subtotal,
                            total: total,
                            currency: currency,
                            showInitiatedBadge: pending,
                            paymentReference: paymentRef,
                            paymentMethod: method,
                          ),
                          if (widget.initiateResult?.message != null &&
                              widget.initiateResult!.message!.isNotEmpty) ...[
                            const SizedBox(height: Spacing.md),
                            _InstructionsCard(
                              instructions: widget.initiateResult!.message!,
                              titleKey: 'checkout.edahabInitiateTitle',
                            ),
                          ],
                          if (instructions.isNotEmpty) ...[
                            const SizedBox(height: Spacing.md),
                            _InstructionsCard(
                              instructions: instructions,
                              titleKey: 'checkout.pending.howToPay',
                            ),
                          ],
                          const SizedBox(height: Spacing.lg),
                          Text.rich(
                            TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: context.tr(
                                    'checkout.orderConfirmedHelpPrefix',
                                  ),
                                ),
                                TextSpan(
                                  text: widget.orderNumber,
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _BottomActions(
                children: <Widget>[
                  AppButton.primary(
                    label: context.tr('checkout.viewOrderHistory'),
                    icon: Icons.receipt_long_outlined,
                    onPressed: () => context.go(AppRoutes.orderHistory),
                  ),
                  const SizedBox(height: Spacing.xs),
                  AppButton.secondary(
                    label: context.tr('checkout.continueShopping'),
                    size: AppButtonSize.medium,
                    onPressed: () => context.go(AppRoutes.dashboard),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Surface bar pinned to the bottom with a top hairline, matching the
/// "Place order" bar on the payment step.
class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            constraints:
                const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// Muted caption shown above a value inside the cards.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _UssdCard extends StatelessWidget {
  const _UssdCard({
    required this.ussdCode,
    this.reference,
  });

  final String ussdCode;
  final String? reference;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Spacing.md,
          Spacing.sm,
          Spacing.xs,
          Spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _FieldLabel(context.tr('checkout.telebirrUssdTitle')),
                      const SizedBox(height: Spacing.xxs),
                      // USSD codes always read left-to-right.
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: SelectableText(
                          ussdCode,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.tr('checkout.copyUssd'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: ussdCode));
                    if (!context.mounted) return;
                    AppSnackbars.success(
                      context,
                      context.tr('checkout.ussdCopied'),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
                IconButton(
                  tooltip: context.tr('checkout.pending.openDialer'),
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
              _FieldLabel(context.tr('checkout.reference')),
              const SizedBox(height: Spacing.xxs),
              SelectableText(reference!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentPendingBanner extends StatelessWidget {
  const _PaymentPendingBanner();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommerceColors commerce = context.commerce;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: commerce.warningContainer,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: commerce.warning,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.tr('checkout.paymentPendingBannerTitle'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: commerce.onWarningContainer,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  context.tr('checkout.paymentPendingBannerBody'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: commerce.onWarningContainer,
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
    required this.orderNumber,
    required this.subtotal,
    required this.total,
    required this.currency,
    required this.showInitiatedBadge,
    this.paymentReference = '',
    this.paymentMethod = '',
  });

  final String orderNumber;
  final num? subtotal;
  final num? total;
  final String currency;
  final bool showInitiatedBadge;
  final String paymentReference;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String currencyLabel =
        CountryCurrencyConstants.getCurrencySymbol(currency);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Spacing.md,
          Spacing.sm,
          Spacing.md,
          Spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _FieldLabel(context.tr('checkout.pending.orderNumber')),
                      const SizedBox(height: Spacing.xxs),
                      SelectableText(
                        orderNumber.isEmpty ? '—' : orderNumber,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                if (showInitiatedBadge)
                  AppBadge(
                    label: context.tr('checkout.statusPending'),
                    tone: AppBadgeTone.warning,
                    icon: Icons.schedule_rounded,
                  ),
                if (orderNumber.isNotEmpty)
                  IconButton(
                    tooltip: context.tr('checkout.copyOrderNumber'),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: orderNumber),
                      );
                      if (!context.mounted) return;
                      AppSnackbars.success(
                        context,
                        context.tr('checkout.orderNumberCopied'),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: AppSizes.iconMd),
                  ),
              ],
            ),
            if (paymentReference.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              _FieldLabel(context.tr('checkout.reference')),
              const SizedBox(height: Spacing.xxs),
              SelectableText(
                paymentReference,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (paymentMethod.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              _FieldLabel(context.tr('checkout.payment')),
              const SizedBox(height: Spacing.xxs),
              Text(paymentMethod, style: theme.textTheme.bodyMedium),
            ],
            const Divider(height: Spacing.xl),
            if (subtotal != null) ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.tr('checkout.subtotal'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  PriceTag(
                    amount: subtotal!,
                    currency: currencyLabel,
                    size: PriceTagSize.small,
                    color: scheme.onSurface,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.tr('checkout.totalDue'),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (total != null)
                  PriceTag(amount: total!, currency: currencyLabel)
                else
                  Text('—', style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({
    required this.instructions,
    required this.titleKey,
  });

  final String instructions;
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                context.tr(titleKey),
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              instructions,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
