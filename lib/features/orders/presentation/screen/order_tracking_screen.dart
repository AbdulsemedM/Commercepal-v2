import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({
    super.key,
    this.orderId,
    this.orderStatus,
  });

  final String? orderId;
  final String? orderStatus; // 'pending', 'confirmed', 'shipped', 'delivered'

  @override
  Widget build(BuildContext context) {
    // Determine current status index (0: placed, 1: pending, 2: waiting, 3: shipped, 4: delivered)
    final int currentStatusIndex = _getCurrentStatusIndex();

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
                    const Spacer(),
                    // App logo
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
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
          ),
          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Order Placed section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Status indicator
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
                      // Status text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Order Placed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              'Tuesday, 28 May 2025',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Product card
                      Container(
                        width: 140,
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Product image placeholder
                            Container(
                              width: double.infinity,
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
                            const SizedBox(height: Spacing.xs),
                            const Text(
                              'Apple iPhone 17 Pro Max',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '1TB',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Price \$ 1,500',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'QTY 1',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xl),
                  // Timeline
                  _buildTimeline(currentStatusIndex),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentStatusIndex() {
    switch (orderStatus?.toLowerCase()) {
      case 'pending':
      case 'pending_confirmation':
        return 1;
      case 'confirmed':
      case 'waiting':
        return 2;
      case 'shipped':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 1; // Default to pending confirmation
    }
  }

  Widget _buildTimeline(int currentIndex) {
    final List<_TimelineItem> items = <_TimelineItem>[
      _TimelineItem(
        title: 'Order Placed',
        tips: '',
        isCompleted: true,
      ),
      _TimelineItem(
        title: 'Pending Confirmation',
        tips:
            'Your order is awaiting a confirmation from the vendor in order to be shipped to your address',
        isCompleted: false,
      ),
      _TimelineItem(
        title: 'Waiting to be shipped',
        tips:
            'Once your order has been accepted it will be packaged and shipped to your address',
        isCompleted: false,
      ),
      _TimelineItem(
        title: 'Shipped',
        tips:
            'Once your order has been packaged it will be dispatched to your delivery address this may take a while depending on your address',
        isCompleted: false,
      ),
      _TimelineItem(
        title: 'Delivered',
        tips:
            'Once your order has been shipped and you have received it the delivery will be complete',
        isCompleted: false,
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Timeline line
        Column(
          children: <Widget>[
            // First completed circle
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
            // Line between circles
            Container(
              width: 2,
              height: 60,
              color: currentIndex > 1
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
            // Second circle (current)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: currentIndex >= 1
                    ? AppColors.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: currentIndex >= 1
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            // Line
            Container(
              width: 2,
              height: 60,
              color: currentIndex > 2
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
            // Third circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: currentIndex >= 2
                    ? AppColors.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: currentIndex >= 2
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            // Line
            Container(
              width: 2,
              height: 60,
              color: currentIndex > 3
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
            // Fourth circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: currentIndex >= 3
                    ? AppColors.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: currentIndex >= 3
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            // Line
            Container(
              width: 2,
              height: 60,
              color: currentIndex > 4
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
            // Fifth circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: currentIndex >= 4
                    ? AppColors.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: currentIndex >= 4
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: Spacing.md),
        // Timeline content
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
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : Spacing.lg,
      ),
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

