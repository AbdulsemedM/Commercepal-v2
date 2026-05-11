import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/constants/spacing.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: scheme.onSurface,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Refund Policy',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title
            Text(
              'CommercePal Refund Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Introduction
                  _buildSection(
                    context,
                    'Introduction',
                    'This Refund Policy outlines the terms and conditions under which refunds may be issued for products and services provided by CommercePal. Our company is dedicated to ensuring customer satisfaction and maintaining transparency in our operations, particularly in the international and local carriage services for a wide range of items, including electronics, fashion, furniture, baby toys, vehicles and accessories, machinery, home style products, raw materials, and chemicals.\n\nBy utilizing our services, you agree to the terms outlined in this policy. Please read carefully to understand your rights and obligations.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Section 1
                  _buildSection(
                    context,
                    '1. Scope of the Refund Policy',
                    'This policy applies to all customers who purchase goods or services from CommercePal, whether they are local or international clients. It covers refunds related to:\n• Electronics\n• Fashion items\n• Furniture\n• Baby toys\n• Vehicles and accessories\n• Machinery\n• Home style products\n• Raw materials and chemicals',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Section 2
                  _buildSection(
                    context,
                    '2. Eligibility for Refunds',
                    '',
                  ),
                  _buildSubSection(
                    context,
                    '2.1 Damaged or Defective Items',
                    '• Customers must report damaged or defective items within 7 consecutive days of receiving the product.\n• Evidence such as photographs or videos of the damage or defect must be provided.\n• Refunds will only be processed if the product is returned in its original packaging.\n• CommercePal will cover the cost of return shipping for approved claims of defective or damaged items.',
                  ),
                  _buildSubSection(
                    context,
                    '2.2 Incorrect Items',
                    '• Customers must notify CommercePal within 30 days of delivery if the received item does not match the order.\n• A full refund or replacement will be provided upon return of the incorrect item.\n• Return shipping costs for incorrect items will be borne by CommercePal.',
                  ),
                  _buildSubSection(
                    context,
                    '2.3 Service Cancellation',
                    '• Customers may cancel carriage services within 24 hours of booking for a full refund.\n• Cancellations made after this period may incur a 20% cancellation fee.',
                  ),
                  _buildSubSection(
                    context,
                    '2.4 Non-Delivery',
                    '• If an item does not arrive within the estimated delivery window, customers should contact our support team within 14 days of the expected delivery date.\n• A refund will be processed if it is determined that the item is lost in transit.',
                  ),
                  _buildSubSection(
                    context,
                    '2.5 Refunds for Partial Orders',
                    '• In cases where part of a multi-item order is eligible for a refund (e.g., one item is defective), the refund will cover only the value of the eligible item(s).',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Section 3
                  _buildSection(
                    context,
                    '3. Non-Refundable Items',
                    '',
                  ),
                  _buildSubSection(
                    context,
                    '3.1 Customized Products',
                    '• Items that have been customized or personalized cannot be returned or refunded unless they are defective.',
                  ),
                  _buildSubSection(
                    context,
                    '3.2 Perishable Goods',
                    '• Perishable items, including certain raw materials and chemicals, are non-refundable due to their nature.',
                  ),
                  _buildSubSection(
                    context,
                    '3.3 Final Sale Items',
                    '• Items marked as "Final Sale" at the time of purchase are not eligible for refunds.',
                  ),
                  _buildSubSection(
                    context,
                    '3.4 Digital or Downloadable Products',
                    '• Refunds for digital or downloadable products will only be granted if there are technical issues that prevent successful access or download.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Section 4
                  _buildSection(
                    context,
                    '4. Refund Process',
                    '',
                  ),
                  _buildSubSection(
                    context,
                    '4.1 Contact Customer Service',
                    '• Customers should contact our customer service team via email at (email address) or phone at (phone number).\n• Provide the order number, a detailed description of the issue, and any supporting documentation (e.g., photos, videos).',
                  ),
                  _buildSubSection(
                    context,
                    '4.2 Return Instructions',
                    '• Upon approval of the refund request, our team will provide instructions on how to return the item.\n• All returns must be securely packaged and sent back to the designated return address within 7 days of receiving return instructions.',
                  ),
                  _buildSubSection(
                    context,
                    '4.3 Refund Timeline',
                    '• Once the returned item is received and inspected, refunds will be processed within 15 business days.\n• Refunds will be issued to the original payment method used at the time of purchase.',
                  ),
                  _buildSubSection(
                    context,
                    '4.4 Refunds for Inactive Payment Methods',
                    '• If the original payment method is no longer active (e.g., expired credit card), CommercePal will issue a refund via an alternative method after verification with the customer.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Section 5
                  _buildSection(
                    context,
                    '5. International Refunds',
                    '',
                  ),
                  _buildSubSection(
                    context,
                    '5.1 Currency Conversion',
                    '• Refunds will be issued in the original currency of the transaction. If currency conversion is applicable, it will be based on the current exchange rate at the time of processing.',
                  ),
                  _buildSubSection(
                    context,
                    '5.2 Customs Duties and Taxes',
                    '• Customers are responsible for any customs duties or taxes incurred during international shipping. These fees are non-refundable.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Section 6
                  _buildSection(
                    context,
                    '6. Dispute Resolution',
                    'If a customer disagrees with a refund decision, they may request a review by contacting a senior representative. For unresolved disputes, CommercePal may involve a third-party mediator to ensure fair resolution.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Section 7
                  _buildSection(
                    context,
                    '7. Exchange Policy',
                    '• Customers may request an exchange instead of a refund, subject to product availability.\n• Exchanges follow the same eligibility and return procedures as refunds.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Section 8
                  _buildSection(
                    context,
                    '8. Changes to the Refund Policy',
                    'CommercePal reserves the right to modify this Refund Policy at any time. Any changes will be posted on our website with an updated effective date. Continued use of our services after such changes constitutes acceptance of the revised policy.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Conclusion
                  _buildSection(
                    context,
                    'Conclusion',
                    'At CommercePal, we strive to provide high-quality products and services while ensuring customer satisfaction. This Refund Policy is designed to protect both our customers and our business interests. We appreciate your understanding and cooperation in adhering to these guidelines.',
                  ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: scheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubSection(BuildContext context, String title, String content) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: Spacing.md, top: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: scheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
