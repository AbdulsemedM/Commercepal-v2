import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class ProductInfoSection extends StatefulWidget {
  const ProductInfoSection({
    super.key,
    required this.title,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.code,
    required this.category,
    required this.keywords,
  });

  final String title;
  final String price;
  final double rating;
  final int reviewCount;
  final String code;
  final String category;
  final String keywords;

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> {
  bool _titleExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Product title: 2 lines by default, tap to expand/collapse
          GestureDetector(
            onTap: () {
              setState(() {
                _titleExpanded = !_titleExpanded;
              });
            },
            child: Text(
              widget.title,
              maxLines: _titleExpanded ? null : 2,
              overflow: _titleExpanded ? null : TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          // Price (large red)
          Text(
            widget.price,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          // Rating and reviews
          Row(
            children: <Widget>[
              _buildStarRating(widget.rating),
              const SizedBox(width: Spacing.xs),
              Text(
                '(${widget.reviewCount} ${widget.reviewCount == 1 ? LocalizationService.t(context, 'productDetail.review') : LocalizationService.t(context, 'productDetail.reviews')})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Code
          _buildDetailRow(
            context,
            LocalizationService.t(context, 'productDetail.code'),
            widget.code,
          ),
          const SizedBox(height: Spacing.xs),
          // Category
          _buildDetailRow(
            context,
            LocalizationService.t(context, 'productDetail.category'),
            widget.category,
            isHighlighted: true,
          ),
          const SizedBox(height: Spacing.xs),
          // Keywords
          _buildDetailRow(
            context,
            LocalizationService.t(context, 'productDetail.keyword'),
            widget.keywords,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        children: <TextSpan>[
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: Colors.grey[700]),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: isHighlighted ? Colors.green : Colors.black,
              fontWeight: isHighlighted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
