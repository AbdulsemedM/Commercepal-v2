import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedTabIndex = 1; // Delivered is selected by default

  final List<String> _tabs = <String>[
    'All',
    'Delivered',
    'Ongoing',
    'Pending Payment',
    'Ca',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: <Widget>[
          // Dark magenta background extending behind status bar
          Container(
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
                    // Back button
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    // Tabs
                    Expanded(
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
                    const SizedBox(width: Spacing.sm),
                    // Help icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content area
          Expanded(
            child: _buildOrderList(),
          ),
        ],
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

  Widget _buildOrderList() {
    // Sample order data
    final List<Map<String, dynamic>> orders = <Map<String, dynamic>>[
      <String, dynamic>{
        'image': 'iphone',
        'name': 'Apple iPhone 17 Pro Max 1TB',
        'orderNumber': '364758488237',
        'date': '20 Oct 2025',
        'status': 'delivered',
      },
      <String, dynamic>{
        'image': 'headphones',
        'name': 'JBL Over-Ear Headphones',
        'orderNumber': '364758488238',
        'date': '18 Oct 2025',
        'status': 'pending',
      },
      <String, dynamic>{
        'image': 'vivo',
        'name': 'Vivo Smartphone',
        'orderNumber': '364758488239',
        'date': '15 Oct 2025',
        'status': 'shipped',
      },
      <String, dynamic>{
        'image': 'ipad',
        'name': 'Apple iPad Pro',
        'orderNumber': '364758488240',
        'date': '12 Oct 2025',
        'status': 'delivered',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.md),
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          // Product image placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
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
                      color: _getStatusColor(order['status'] as String? ?? 'pending'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(order['status'] as String? ?? 'pending'),
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
                  order['name'] as String,
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
                  'Order #${order['orderNumber']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                // Date
                Text(
                  order['date'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Arrow icon
          InkWell(
            onTap: () {
              // Check if order is delivered
              final String status = order['status'] as String? ?? 'pending';
              if (status.toLowerCase() == 'delivered') {
                context.push('/order-summary?id=${order['orderNumber']}');
              } else {
                context.push(
                  '/order-tracking?id=${order['orderNumber']}&status=$status',
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
        return Colors.green.shade100;
      case 'shipped':
        return Colors.blue.shade100;
      case 'pending':
      case 'pending_confirmation':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Delivered';
      case 'shipped':
        return 'Shipped';
      case 'pending':
      case 'pending_confirmation':
        return 'Pending';
      case 'confirmed':
      case 'waiting':
        return 'Waiting';
      default:
        return 'Pending';
    }
  }
}

