import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/orders/bloc/orders_bloc.dart';
import 'package:commercepal/features/orders/data/models/order.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedTabIndex = 0; // All is selected by default

  final List<String> _tabs = <String>[
    'All',
    'Delivered',
    'Ongoing',
    'Pending Payment',
    'Cancelled',
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

  @override
  void initState() {
    super.initState();
    // Load orders when screen initializes - use postFrameCallback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔵 OrderHistoryScreen: Dispatching OrdersLoadRequested event');
        try {
          final bloc = context.read<OrdersBloc>();
          print('🔵 OrderHistoryScreen: BLoC found, adding event');
          bloc.add(OrdersLoadRequested());
        } catch (e) {
          print('❌ OrderHistoryScreen: Error accessing BLoC: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List<Widget>.generate(
                  _tabs.length,
                  (int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                      ),
                      child: _buildTab(index, _tabs[index]),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          print('🔵 OrderHistoryScreen: BlocBuilder rebuild - state: ${state.runtimeType}');
          if (state is OrdersLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.md),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OrdersBloc>().add(
                            OrdersLoadRequested(
                              stageCategory: _getStageCategoryForTab(_selectedTabIndex),
                            ),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is OrdersLoaded) {
            return _buildOrderList(state.response.content);
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
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
        // Reload orders with the selected filter
        context.read<OrdersBloc>().add(
              OrdersLoadRequested(
                stageCategory: _getStageCategoryForTab(index),
              ),
            );
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
                color: isSelected ? Colors.black87 : Colors.grey.shade600,
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
              'No orders found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersBloc>().add(
              OrdersRefreshRequested(
                stageCategory: _getStageCategoryForTab(_selectedTabIndex),
              ),
            );
        // Wait a bit for the refresh to complete
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
    final productName = firstItem?.productName ?? 'Multiple items';
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

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                : Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
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
                        : _getStatusLabel(status),
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
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                // Order number
                Text(
                  'Order #${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
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
                      '${order.currency} ${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Arrow icon
          InkWell(
            onTap: () {
              // Check if order is delivered
              if (order.stageCategory.toLowerCase() == 'delivered' ||
                  status == 'delivered') {
                context.push('/order-summary?id=${order.orderNumber}');
              } else {
                context.push(
                  '/order-tracking?id=${order.orderNumber}&status=$status',
                );
              }
            },
            child: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ],
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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Delivered';
      case 'shipped':
      case 'ongoing':
        return 'Ongoing';
      case 'pending':
      case 'pending_confirmation':
      case 'pending_payment':
        return 'Pending Payment';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'confirmed':
      case 'waiting':
        return 'Waiting';
      default:
        return 'Pending';
    }
  }
}

