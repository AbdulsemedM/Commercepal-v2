import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
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
    this.originalPrice,
    this.isOnDiscount = false,
    this.vendorName,
    this.stockLevel,
    this.status,
    this.stuffStatus,
    this.createdTime,
    this.updatedTime,
    this.isSellAllowed = true,
    this.variantSelector,
  });

  final String title;
  final String price;
  final String? originalPrice;
  final bool isOnDiscount;
  final double rating;
  final int reviewCount;
  final String code;
  final String category;
  final String keywords;
  final String? vendorName;
  final int? stockLevel;
  final String? status;
  final String? stuffStatus;
  final String? createdTime;
  final String? updatedTime;
  final bool isSellAllowed;
  final Widget? variantSelector;

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> {
  bool _titleExpanded = false;

  bool get _inStock =>
      widget.isSellAllowed &&
      (widget.stockLevel == null || widget.stockLevel! > 0);

  bool get _isNew {
    final String status = (widget.stuffStatus ?? '').toLowerCase();
    if (status.contains('new')) return true;
    final DateTime? created = DateTime.tryParse(widget.createdTime ?? '');
    if (created == null) return false;
    return DateTime.now().difference(created).inDays <= 30;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() => _titleExpanded = !_titleExpanded);
            },
            child: Text(
              widget.title,
              maxLines: _titleExpanded ? null : 2,
              overflow: _titleExpanded ? null : TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.navy,
                    height: 1.3,
                  ),
            ),
          ),
          if (widget.rating > 0 || widget.reviewCount > 0) ...[
            const SizedBox(height: Spacing.xs),
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
          ],
          if (widget.price.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Text(
                    widget.price,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.pink,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                  ),
                ),
                if (widget.isOnDiscount &&
                    widget.originalPrice != null &&
                    widget.originalPrice!.isNotEmpty) ...[
                  const SizedBox(width: Spacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      widget.originalPrice!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (widget.variantSelector != null) ...[
            const SizedBox(height: Spacing.md),
            widget.variantSelector!,
          ],
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: <Widget>[
              if (_inStock) _StatusBadge.inStock(),
              if (!_inStock) _StatusBadge.outOfStock(),
              if (_isNew) _StatusBadge.isNew(),
            ],
          ),
          if (_hasDates) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              _datesLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
            ),
          ],
          if (widget.code.isNotEmpty || widget.category.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            _GeneralInfoCard(
              code: widget.code,
              category: widget.category,
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasDates =>
      (widget.createdTime != null && widget.createdTime!.isNotEmpty) ||
      (widget.updatedTime != null && widget.updatedTime!.isNotEmpty);

  String get _datesLine {
    final List<String> parts = <String>[];
    if (widget.createdTime != null && widget.createdTime!.isNotEmpty) {
      parts.add('Listed ${_formatDate(widget.createdTime!)}');
    }
    if (widget.updatedTime != null && widget.updatedTime!.isNotEmpty) {
      parts.add('Updated ${_formatDate(widget.updatedTime!)}');
    }
    return parts.join(' · ');
  }

  String _formatDate(String isoDate) {
    final DateTime? d = DateTime.tryParse(isoDate);
    if (d == null) return isoDate;
    return DateFormat('d MMM yyyy').format(d.toLocal());
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: AppColors.secondary, size: 16);
        } else if (index < rating) {
          return const Icon(
            Icons.star_half,
            color: AppColors.secondary,
            size: 16,
          );
        } else {
          return Icon(Icons.star_border, color: Colors.grey[400], size: 16);
        }
      }),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge._({
    required this.label,
    required this.background,
    required this.foreground,
    this.showDot = false,
  });

  factory _StatusBadge.inStock() => const _StatusBadge._(
        label: 'In stock',
        background: Color(0xFFE8F8EF),
        foreground: AppColors.success,
        showDot: true,
      );

  factory _StatusBadge.outOfStock() => const _StatusBadge._(
        label: 'Out of stock',
        background: Color(0xFFFEE2E2),
        foreground: AppColors.error,
      );

  factory _StatusBadge.isNew() => const _StatusBadge._(
        label: 'New',
        background: Color(0xFFFFF3D6),
        foreground: Color(0xFFB45309),
      );

  final String label;
  final Color background;
  final Color foreground;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralInfoCard extends StatelessWidget {
  const _GeneralInfoCard({
    required this.code,
    required this.category,
  });

  final String code;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: AppDecorations.elevatedCard(background: Colors.white),
      child: Column(
        children: <Widget>[
          if (code.isNotEmpty)
            _InfoRow(
              label: LocalizationService.t(context, 'productDetail.code'),
              child: Text(
                code,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
              ),
            ),
          if (code.isNotEmpty && category.isNotEmpty)
            Divider(height: Spacing.lg, color: Colors.grey[200]),
          if (category.isNotEmpty)
            _InfoRow(
              label: LocalizationService.t(context, 'productDetail.category'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppDecorations.softCream,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        Flexible(child: Align(alignment: Alignment.centerRight, child: child)),
      ],
    );
  }
}
