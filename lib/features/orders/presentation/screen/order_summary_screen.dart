import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({
    super.key,
    this.orderId,
  });

  final String? orderId;

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
                    const Spacer(),
                    // Chat icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                  // Your Order Summary section
                  _buildSection(
                    'Your Order Summary',
                    <Widget>[
                      _buildInfoRow('Order #', '364758488237'),
                      const SizedBox(height: Spacing.sm),
                      _buildInfoRow('Placed on', '19-11-2025'),
                      const SizedBox(height: Spacing.sm),
                      _buildInfoRow('Number of items', '1'),
                      const SizedBox(height: Spacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '\$1,574.88',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Items in your order section
                  _buildSection(
                    'Items in your order',
                    <Widget>[
                      Text(
                        'Delivered on 20-11-2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Container(
                        padding: const EdgeInsets.all(Spacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: <Widget>[
                            // Product image placeholder
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: Spacing.md),
                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Delivered badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Spacing.sm,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Delivered',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.sm),
                                  const Text(
                                    'Apple iPhone 17 Pro Max 1TB',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.xs),
                                  Text(
                                    'Price \$ 1,500',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.xs),
                                  Text(
                                    'QTY 1',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Payment Method section
                  _buildSection(
                    'Payment Method',
                    <Widget>[
                      Container(
                        padding: const EdgeInsets.all(Spacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'Paid via Visa/Master Card',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                // VISA logo placeholder
                                Container(
                                  width: 40,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'VISA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: Spacing.xs),
                                // Mastercard logo placeholder
                                Container(
                                  width: 40,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'MC',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Delivered to section
                  _buildSection(
                    'Delivered to',
                    <Widget>[
                      Container(
                        padding: const EdgeInsets.all(Spacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Alex Wanjohi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              'Nairobi, Kenya',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: Spacing.md),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

