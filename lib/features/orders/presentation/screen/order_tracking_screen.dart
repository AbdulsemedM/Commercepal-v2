import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/features/orders/bloc/order_tracking_cubit.dart';
import 'package:commercepal/features/orders/data/models/order.dart';
import 'package:commercepal/features/orders/data/models/order_item.dart';
import 'package:commercepal/services/invoice_pdf_service.dart';

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
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: <Widget>[
          _buildAppBar(context),
          Expanded(
            child: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
              builder: (context, state) {
                if (state is OrderTrackingLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state is OrderTrackingError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: Spacing.md),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          TextButton.icon(
                            onPressed: () {
                              if (widget.orderId != null) {
                                context
                                    .read<OrderTrackingCubit>()
                                    .loadOrderByOrderNumber(widget.orderId!);
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/app_icon.png',
                width: 40,
                height: 40,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
              ),
            ],
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
    final currentStatusIndex = _getCurrentStatusIndex(order);
    final statusLabel = order.stageLabel.isNotEmpty
        ? order.stageLabel
        : _defaultStageLabel(currentStatusIndex);
    final orderDateFormatted = _formatOrderDate(order.orderDate);
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (fromCache)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: Spacing.md),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.cloud_off_outlined, color: Colors.amber.shade900),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'Showing the last saved copy of this order. '
                      'Reconnect and use Retry to refresh.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      orderDateFormatted,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (order.orderNumber.isNotEmpty) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Order #${order.orderNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (firstItem != null)
                _buildProductCard(firstItem, order.currency),
            ],
          ),
          const SizedBox(height: Spacing.xl),
          OutlinedButton.icon(
            onPressed: _isGeneratingInvoice ? null : () => _downloadInvoice(context, order),
            icon: _isGeneratingInvoice
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(
              _isGeneratingInvoice ? 'Generating…' : 'Download invoice (PDF)',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          _buildTimeline(currentStatusIndex),
        ],
      ),
    );
  }

  Widget _buildProductCard(OrderItem item, String currency) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.productImageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : Icon(Icons.image, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            item.productName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.productConfiguration.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.productConfiguration,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 2),
          Text(
            '${MoneyFormatter.format(item.unitPrice, currency)}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 2),
          Text(
            'QTY ${item.quantity}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadInvoice(BuildContext context, Order order) async {
    setState(() => _isGeneratingInvoice = true);
    try {
      final pdfBytes = await InvoicePdfService.buildPdf(order: order);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice_${order.orderNumber}.pdf');
      await file.writeAsBytes(pdfBytes);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice - Order ${order.orderNumber}',
        text: 'Your CommercePal invoice for order ${order.orderNumber}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice ready. Save or share the PDF.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate invoice: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingInvoice = false);
    }
  }

  int _getCurrentStatusIndex(Order order) {
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

  String _defaultStageLabel(int index) {
    const labels = <String>[
      'Order Placed',
      'Pending Confirmation',
      'Waiting to be shipped',
      'Shipped',
      'Delivered',
    ];
    if (index >= 0 && index < labels.length) return labels[index];
    return 'Order Placed';
  }

  String _formatOrderDate(String orderDate) {
    if (orderDate.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(orderDate);
      if (parsed != null) {
        return DateFormat('EEEE, d MMM y').format(parsed);
      }
      return orderDate;
    } catch (_) {
      return orderDate;
    }
  }

  Widget _buildTimeline(int currentIndex) {
    final List<_TimelineItem> items = <_TimelineItem>[
      const _TimelineItem(title: 'Order Placed', tips: '', isCompleted: true),
      const _TimelineItem(
        title: 'Pending Confirmation',
        tips:
            'Your order is awaiting a confirmation from the vendor in order to be shipped to your address',
        isCompleted: false,
      ),
      const _TimelineItem(
        title: 'Waiting to be shipped',
        tips:
            'Once your order has been accepted it will be packaged and shipped to your address',
        isCompleted: false,
      ),
      const _TimelineItem(
        title: 'Shipped',
        tips:
            'Once your order has been packaged it will be dispatched to your delivery address this may take a while depending on your address',
        isCompleted: false,
      ),
      const _TimelineItem(
        title: 'Delivered',
        tips:
            'Once your order has been shipped and you have received it the delivery will be complete',
        isCompleted: false,
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            _timelineCircle(true),
            _timelineLine(currentIndex > 1),
            _timelineCircle(currentIndex >= 1),
            _timelineLine(currentIndex > 2),
            _timelineCircle(currentIndex >= 2),
            _timelineLine(currentIndex > 3),
            _timelineCircle(currentIndex >= 3),
            _timelineLine(currentIndex > 4),
            _timelineCircle(currentIndex >= 4),
          ],
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTimelineItem(items[0], 0, currentIndex, isFirst: true),
              _buildTimelineItem(items[1], 1, currentIndex),
              _buildTimelineItem(items[2], 2, currentIndex),
              _buildTimelineItem(items[3], 3, currentIndex),
              _buildTimelineItem(items[4], 4, currentIndex, isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timelineCircle(bool filled) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? AppColors.primary : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: filled
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }

  Widget _timelineLine(bool filled) {
    return Container(
      width: 2,
      height: 60,
      color: filled ? AppColors.primary : Colors.grey.shade300,
    );
  }

  Widget _buildTimelineItem(
    _TimelineItem item,
    int index,
    int currentIndex, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final bool isActive = index == currentIndex;
    final bool isCompleted = index < currentIndex;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive || isCompleted
                  ? AppColors.primary
                  : Colors.grey.shade600,
            ),
          ),
          if (item.tips.isNotEmpty) ...<Widget>[
            const SizedBox(height: Spacing.xs),
            Text(
              item.tips,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem {
  const _TimelineItem({
    required this.title,
    required this.tips,
    required this.isCompleted,
  });

  final String title;
  final String tips;
  final bool isCompleted;
}
