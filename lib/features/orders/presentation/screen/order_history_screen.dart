import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/orders/bloc/orders_bloc.dart';
import 'package:commercepal/features/orders/data/models/order.dart';
import 'package:commercepal/features/orders/data/repository/orders_repository.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedTabIndex = 0;

  static const List<String> _tabKeys = [
    'orderHistory.all',
    'orderHistory.delivered',
    'orderHistory.ongoing',
    'orderHistory.pendingPayment',
    'orderHistory.cancelled',
  ];

  String? _getStageCategoryForTab(int index) {
    switch (index) {
      case 0:
        return null; // All
      case 1:
        return 'DELIVERED';
      case 2:
        return 'ONGOING';
      case 3:
        return 'PENDING_PAYMENT';
      case 4:
        return 'CANCELLED';
      default:
        return null;
    }
  }

  /// Returns true if [order] belongs to the given tab [stageCategory].
  /// [stageCategory] null means "All". Matches order.stageCategory and order.currentStage.
  bool _orderMatchesTab(Order order, String? stageCategory) {
    if (stageCategory == null || stageCategory.isEmpty) return true;
    final cat = stageCategory.toUpperCase();
    final orderCat = order.stageCategory.toUpperCase();
    final orderStage = order.currentStage.toUpperCase();

    if (orderCat == cat) return true;
    if (orderStage == cat) return true;

    // Aliases for common API variations
    switch (cat) {
      case 'DELIVERED':
        return orderCat.contains('DELIVERED') || orderStage.contains('DELIVERED');
      case 'ONGOING':
        return orderCat.contains('ONGOING') ||
            orderStage.contains('ONGOING') ||
            orderCat.contains('SHIPPED') ||
            orderStage.contains('SHIPPED') ||
            orderCat.contains('CONFIRMED') ||
            orderStage.contains('CONFIRMED') ||
            orderCat.contains('PROCESSING') ||
            orderStage.contains('PROCESSING');
      case 'PENDING_PAYMENT':
        return orderCat.contains('PENDING') && orderCat.contains('PAYMENT') ||
            orderStage.contains('PENDING') && orderStage.contains('PAYMENT') ||
            orderCat.contains('WAITING') ||
            orderStage.contains('WAITING') ||
            orderCat == 'PENDING_PAYMENT' ||
            orderStage == 'PENDING_PAYMENT';
      case 'CANCELLED':
        return orderCat.contains('CANCEL') || orderStage.contains('CANCEL');
      default:
        return orderCat == cat || orderStage == cat;
    }
  }

  final OrdersRepository _ordersRepository = OrdersRepository();

  @override
  void initState() {
    super.initState();
    // Load orders when screen initializes - use postFrameCallback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // print('🔵 OrderHistoryScreen: Dispatching OrdersLoadRequested event');
        try {
          final bloc = context.read<OrdersBloc>();
          // print('🔵 OrderHistoryScreen: BLoC found, adding event');
          bloc.add(OrdersLoadRequested());
        } catch (e) {
          // print('❌ OrderHistoryScreen: Error accessing BLoC: $e');
        }
      }
    });
  }

  /// Opens payment method selection to pay for an order (Waiting for Payment).
  /// Fetches order detail if paymentReference is not in the list item.
  Future<void> _openPayForOrder(BuildContext context, Order order) async {
    String? paymentRef = order.paymentReference;
    if (paymentRef == null || paymentRef.isEmpty) {
      try {
        final detail = await _ordersRepository.getOrderByOrderNumber(order.orderNumber);
        paymentRef = detail.paymentReference;
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocalizationService.t(context, 'orderHistory.unableToLoadPayment')),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }
    if (paymentRef == null || paymentRef.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.t(context, 'orderHistory.paymentNotAvailable')),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }
    if (!context.mounted) return;
    context.push<void>(
      AppRoutes.retryPaymentMethod,
      extra: <String, dynamic>{
        'paymentReference': paymentRef,
        'currency': order.currency,
        'orderNumber': order.orderNumber,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageBg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: AppDecorations.softCream,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.navy,
            ),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: Text(
          LocalizationService.t(context, 'orderHistory.title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List<Widget>.generate(_tabKeys.length, (int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                    child: _buildTab(index, LocalizationService.t(context, _tabKeys[index])),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          // print(
          //   '🔵 OrderHistoryScreen: BlocBuilder rebuild - state: ${state.runtimeType}',
          // );
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.md),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OrdersBloc>().add(OrdersLoadRequested());
                    },
                    child: Text(LocalizationService.t(context, 'orderHistory.retry')),
                  ),
                ],
              ),
            );
          }

          if (state is OrdersLoaded) {
            final category = _getStageCategoryForTab(_selectedTabIndex);
            final filtered = state.response.content
                .where((Order o) => _orderMatchesTab(o, category))
                .toList();
            return _buildOrderList(filtered);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final bool isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        // Filtering is done client-side from the already-loaded list; no need to reload.
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.navy : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                height: 2,
                width: label.length * 7.0,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                ),
              )
            else
              const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              LocalizationService.t(context, 'orderHistory.noOrdersFound'),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersBloc>().add(
          OrdersRefreshRequested(),
        );
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(Spacing.md),
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    // Get first item for display
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final productName = firstItem?.productName ?? LocalizationService.t(context, 'orderHistory.multipleItems');
    final productImageUrl = firstItem?.productImageUrl ?? '';

    // Format date
    String formattedDate = '';
    try {
      final dateTime = DateTime.parse(order.orderDate);
      formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      formattedDate = order.orderDate;
    }

    // Determine status from stageCategory or currentStage
    final status = order.stageCategory.isNotEmpty
        ? order.stageCategory.toLowerCase()
        : order.currentStage.toLowerCase();

    void goToOrderDetails() {
      if (order.stageCategory.toLowerCase() == 'delivered' ||
          order.currentStage.toLowerCase() == 'delivered') {
        context.push('/order-summary?id=${order.orderNumber}');
      } else {
        context.pushNamed(
          'orderTracking',
          queryParameters: {
            'id': order.orderNumber,
            'status': status,
          },
          extra: order,
        );
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: goToOrderDetails,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: Spacing.md),
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
            boxShadow: AppDecorations.softCardShadow(),
          ),
          child: Row(
            children: <Widget>[
              // Product image
              Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: productImageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      productImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
                  )
                : Icon(Icons.image, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(width: Spacing.md),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.stageLabel.isNotEmpty
                        ? order.stageLabel
                        : _getStatusLabel(context, status),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                // Product name
                Text(
                  order.items.length > 1
                      ? '$productName + ${order.items.length - 1} more'
                      : productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                // Order number
                Text(
                  '${LocalizationService.t(context, 'orderHistory.orderNumber')}${order.orderNumber}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: Spacing.xs),
                // Date and total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${MoneyFormatter.format(order.totalAmount, order.currency)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                // Actions: Pay and Track (from API actions.canPay / actions.canTrack)
                if (order.canPay || order.canTrack) ...[
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      if (order.canPay)
                        Padding(
                          padding: const EdgeInsets.only(right: Spacing.xs),
                          child: OutlinedButton(
                            onPressed: () => _openPayForOrder(context, order),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(LocalizationService.t(context, 'orderHistory.pay')),
                          ),
                        ),
                      if (order.canTrack)
                        OutlinedButton(
                          onPressed: () {
                            // Prevent card tap when pressing Track
                            context.pushNamed(
                              'orderTracking',
                              queryParameters: {
                                'id': order.orderNumber,
                                'status': status,
                              },
                              extra: order,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(LocalizationService.t(context, 'orderHistory.track')),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
              // Chevron (same as card tap: go to details)
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'all':
        return Colors.green.shade100;
      case 'shipped':
      case 'ongoing':
        return Colors.blue.shade100;
      case 'pending':
      case 'pending_confirmation':
      case 'pending_payment':
        return Colors.orange.shade100;
      case 'cancelled':
      case 'canceled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  String _getStatusLabel(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return LocalizationService.t(context, 'orderHistory.delivered');
      case 'shipped':
      case 'ongoing':
        return LocalizationService.t(context, 'orderHistory.ongoing');
      case 'pending':
      case 'pending_confirmation':
      case 'pending_payment':
        return LocalizationService.t(context, 'orderHistory.pendingPayment');
      case 'cancelled':
      case 'canceled':
        return LocalizationService.t(context, 'orderHistory.cancelled');
      case 'confirmed':
      case 'waiting':
        return LocalizationService.t(context, 'orderHistory.waiting');
      default:
        return LocalizationService.t(context, 'orderHistory.pending');
    }
  }
}
