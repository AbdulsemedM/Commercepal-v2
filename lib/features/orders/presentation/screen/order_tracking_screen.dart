import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/orders/bloc/order_tracking_cubit.dart';
import 'package:commercepal/features/orders/data/models/order.dart';
import 'package:commercepal/features/orders/data/models/order_item.dart';
import 'package:commercepal/features/orders/presentation/widgets/order_item_thumbnail.dart';
import 'package:commercepal/features/orders/presentation/widgets/order_section_card.dart';
import 'package:commercepal/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:commercepal/features/checkout/data/models/payment_flow_constants.dart';
import 'package:commercepal/services/invoice_pdf_service.dart';
import 'package:commercepal/services/localization_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    super.key,
    this.order,
    this.orderId,
    this.orderStatus,
  });

  /// When coming from order history, pass the full [Order] to avoid an extra API call.
  final Order? order;
  final String? orderId;
  final String? orderStatus;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _isGeneratingInvoice = false;

  /// Timeline step titles, in order (index matches [_getCurrentStatusIndex]).
  static const List<String> _stepTitleKeys = <String>[
    'orders.tracking.stepPlaced',
    'orders.tracking.stepConfirmation',
    'orders.tracking.stepProcessing',
    'orders.tracking.stepShipped',
    'orders.tracking.stepDelivered',
  ];

  static const List<String> _stepTipKeys = <String>[
    '',
    'orders.tracking.tipConfirmation',
    'orders.tracking.tipProcessing',
    'orders.tracking.tipShipped',
    'orders.tracking.tipDelivered',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<OrderTrackingCubit>();
      if (widget.order != null) {
        cubit.setOrder(widget.order!);
      } else if (widget.orderId != null && widget.orderId!.isNotEmpty) {
        cubit.loadOrderByOrderNumber(widget.orderId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: context.tr('common.goBack'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Semantics(
          header: true,
          child: Text(context.tr('orders.tracking.title')),
        ),
      ),
      body: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
        builder: (context, state) {
          if (state is OrderTrackingLoading) {
            return _buildLoading();
          }
          if (state is OrderTrackingError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              isError: true,
              title: context.tr('common.somethingWentWrong'),
              subtitle: state.message,
              primaryLabel: context.tr('common.retry'),
              onPrimary: () {
                if (widget.orderId != null) {
                  context
                      .read<OrderTrackingCubit>()
                      .loadOrderByOrderNumber(widget.orderId!);
                }
              },
            );
          }
          if (state is OrderTrackingLoaded) {
            return _buildContent(
              context,
              state.order,
              fromCache: state.fromCache,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
        builder: (context, state) {
          if (state is! OrderTrackingLoaded) return const SizedBox.shrink();
          return _buildBottomBar(context, state.order);
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Spacing.gutter),
      children: const <Widget>[
        ShimmerLoading(height: 120, width: double.infinity),
        SizedBox(height: Spacing.sm),
        ListTileShimmer(),
        ListTileShimmer(),
        SizedBox(height: Spacing.sm),
        ShimmerLoading(height: 240, width: double.infinity),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Order order) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.commerce.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.sm,
              Spacing.gutter,
              Spacing.sm,
            ),
            child: AppButton.secondary(
              label: _isGeneratingInvoice
                  ? context.tr('checkout.generating')
                  : context.tr('checkout.downloadInvoicePdf'),
              icon: Icons.download_rounded,
              loading: _isGeneratingInvoice,
              onPressed: _isGeneratingInvoice
                  ? null
                  : () => _downloadInvoice(context, order),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Order order, {
    bool fromCache = false,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    final currentStatusIndex = _getCurrentStatusIndex(order);
    final statusLabel = order.stageLabel.isNotEmpty
        ? order.stageLabel
        : _defaultStageLabel(context, currentStatusIndex);
    final orderDateFormatted = _formatOrderDate(context, order.orderDate);
    final String statusKey = OrderStatusBadge.pickStatus(
      <String>[order.currentStage, order.stageCategory],
    );

    return ListView(
      padding: const EdgeInsets.all(Spacing.gutter),
      children: <Widget>[
        if (fromCache)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: commerce.warningContainer,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.cloud_off_outlined,
                      color: commerce.onWarningContainer,
                      size: AppSizes.iconMd,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        context.tr('orders.tracking.offlineCopy'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: commerce.onWarningContainer,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Status header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OrderStatusBadge(status: statusKey, label: statusLabel),
                const SizedBox(height: Spacing.xs),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (orderDateFormatted.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    context.tr('orders.history.placedOn', {
                      'date': orderDateFormatted,
                    }),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (order.orderNumber.isNotEmpty)
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          '${context.tr('orderHistory.orderNumber')}${order.orderNumber}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: AppSizes.iconSm,
                        tooltip: context.tr('checkout.copyOrderNumber'),
                        icon: Icon(
                          Icons.copy_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: order.orderNumber),
                          );
                          AppSnackbars.success(
                            context,
                            context.tr('checkout.orderNumberCopied'),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (order.items.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.sm),
          OrderSectionCard(
            title: order.items.length == 1
                ? context.tr('orders.itemCountOne')
                : context.tr('checkout.itemsCount', {
                    'count': order.items.length,
                  }),
            icon: Icons.inventory_2_outlined,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < order.items.length; i++) ...<Widget>[
                  if (i > 0)
                    Divider(height: Spacing.lg, color: commerce.border),
                  _buildProductRow(order.items[i], order.currency),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: Spacing.sm),
        OrderSectionCard(
          title: context.tr('orders.tracking.timelineTitle'),
          icon: Icons.timeline_rounded,
          child: _buildTimeline(order, currentStatusIndex),
        ),
      ],
    );
  }

  Widget _buildProductRow(OrderItem item, String currency) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OrderItemThumbnail(
          url: item.productImageUrl,
          size: 64,
          semanticLabel: item.productName,
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.productName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.productConfiguration.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item.productConfiguration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: Spacing.xxs),
              Row(
                children: <Widget>[
                  Flexible(
                    child: PriceTag(
                      amount: item.unitPrice,
                      currency:
                          CountryCurrencyConstants.getCurrencySymbol(currency),
                      size: PriceTagSize.small,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    context.tr('orders.qty', {'count': item.quantity}),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadInvoice(BuildContext context, Order order) async {
    // Resolve localised copy before any async gap.
    final String shareSubject = context.tr(
      'checkout.orderPlaced.invoiceShareSubject',
      {'orderNumber': order.orderNumber},
    );
    final String shareText = context.tr(
      'checkout.orderPlaced.invoiceShareText',
      {'orderNumber': order.orderNumber},
    );
    final String readyMessage = context.tr('checkout.invoiceReady');
    final String failedMessage = context.tr('checkout.failedToGenerateInvoice');

    setState(() => _isGeneratingInvoice = true);
    try {
      final pdfBytes = await InvoicePdfService.buildPdf(order: order);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice_${order.orderNumber}.pdf');
      await file.writeAsBytes(pdfBytes);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: shareSubject,
        text: shareText,
      );
      if (mounted && context.mounted) {
        AppSnackbars.success(context, readyMessage);
      }
    } catch (e) {
      if (mounted && context.mounted) {
        AppSnackbars.error(context, failedMessage);
      }
    } finally {
      if (mounted) setState(() => _isGeneratingInvoice = false);
    }
  }

  /// Timeline index for a raw stage code, or null when the stage isn't known.
  int? _indexForStage(String rawStage) {
    final stage = rawStage.toUpperCase();
    switch (stage) {
      case OrderStage.paymentPending:
      case 'PENDING':
      case OrderStage.paymentConfirmed:
        return 1;
      case OrderStage.processing:
      case OrderStage.packed:
        return 2;
      case OrderStage.shipped:
      case OrderStage.outForDelivery:
        return 3;
      case OrderStage.delivered:
        return 4;
    }
    return null;
  }

  int _getCurrentStatusIndex(Order order) {
    final int? fromStage = _indexForStage(order.currentStage);
    if (fromStage != null) return fromStage;

    final category = order.stageCategory.toUpperCase();
    switch (category) {
      case 'PENDING_CONFIRMATION':
      case 'PENDING':
        return 1;
      case 'CONFIRMED':
      case 'ONGOING':
      case 'WAITING':
        return 2;
      case 'SHIPPED':
        return 3;
      case 'DELIVERED':
        return 4;
      default:
        return 1;
    }
  }

  String _defaultStageLabel(BuildContext context, int index) {
    const labels = <String>[
      'orders.tracking.stepPlaced',
      'orders.tracking.stagePaymentPending',
      'orders.tracking.stepProcessing',
      'orders.tracking.stepShipped',
      'orders.tracking.stepDelivered',
    ];
    if (index >= 0 && index < labels.length) return context.tr(labels[index]);
    return context.tr('orders.tracking.stepPlaced');
  }

  String _formatOrderDate(BuildContext context, String orderDate) {
    if (orderDate.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(orderDate);
      if (parsed != null) {
        return formatOrderDate(context, parsed, 'EEEE, d MMM y');
      }
      return orderDate;
    } catch (_) {
      return orderDate;
    }
  }

  /// Most recent time each timeline step was entered, from stage history.
  Map<int, String> _stepDates(BuildContext context, Order order) {
    final Map<int, String> dates = <int, String>{};
    final String placed = _formatOrderDate(context, order.orderDate);
    if (placed.isNotEmpty) dates[0] = placed;
    for (final OrderStageHistoryEntry entry
        in order.orderStageHistory ?? const <OrderStageHistoryEntry>[]) {
      final int? index = _indexForStage(entry.stage);
      final DateTime? at = DateTime.tryParse(entry.enteredAt);
      if (index == null || at == null) continue;
      dates[index] = formatOrderDate(context, at.toLocal(), 'd MMM y, HH:mm');
    }
    return dates;
  }

  Widget _buildTimeline(Order order, int currentIndex) {
    final Map<int, String> dates = _stepDates(context, order);
    final int last = _stepTitleKeys.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i <= last; i++)
          _buildTimelineItem(
            title: context.tr(_stepTitleKeys[i]),
            tips: _stepTipKeys[i].isEmpty ? '' : context.tr(_stepTipKeys[i]),
            date: dates[i],
            state: i < currentIndex || (i == currentIndex && i == last)
                ? _StepState.done
                : i == currentIndex
                    ? _StepState.current
                    : _StepState.upcoming,
            lineDone: i < currentIndex,
            isLast: i == last,
          ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String tips,
    required String? date,
    required _StepState state,
    required bool lineDone,
    required bool isLast,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;

    final Color dotColor = switch (state) {
      _StepState.done => commerce.success,
      _StepState.current => scheme.primary,
      _StepState.upcoming => scheme.outlineVariant,
    };
    final Color lineColor =
        lineDone ? commerce.success : scheme.outlineVariant;

    final Widget dot = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: state == _StepState.upcoming ? scheme.surface : dotColor,
        shape: BoxShape.circle,
        border: Border.all(color: dotColor, width: 2),
      ),
      alignment: Alignment.center,
      child: switch (state) {
        _StepState.done =>
          Icon(Icons.check_rounded, size: 16, color: commerce.successContainer),
        _StepState.current => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: scheme.onPrimary,
              shape: BoxShape.circle,
            ),
          ),
        _StepState.upcoming => null,
      },
    );

    final String stateLabel = switch (state) {
      _StepState.done => context.tr('orders.tracking.stateDone'),
      _StepState.current => context.tr('orders.tracking.stateCurrent'),
      _StepState.upcoming => context.tr('orders.tracking.stateUpcoming'),
    };

    return Semantics(
      container: true,
      label: '$title, $stateLabel',
      liveRegion: state == _StepState.current,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 24,
              child: Column(
                children: <Widget>[
                  dot,
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: lineColor,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 2,
                  bottom: isLast ? 0 : Spacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: switch (state) {
                          _StepState.done => scheme.onSurface,
                          _StepState.current => scheme.primary,
                          _StepState.upcoming => scheme.onSurfaceVariant,
                        },
                        fontWeight: state == _StepState.upcoming
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                    if (date != null && date.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFeatures: AppTypography.tabularFigures,
                        ),
                      ),
                    ],
                    if (tips.isNotEmpty) ...<Widget>[
                      const SizedBox(height: Spacing.xxs),
                      Text(
                        tips,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, current, upcoming }
