import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../data/models/customer_review.dart';

/// Rating summary plus the first few reviews.
class ReviewsSectionWidget extends StatelessWidget {
  const ReviewsSectionWidget({
    super.key,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    this.onViewAllTap,
    this.maxReviewsToShow = 3,
  });

  final List<CustomerReview> reviews;
  final double averageRating;
  final int totalReviews;
  final VoidCallback? onViewAllTap;
  final int maxReviewsToShow;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<CustomerReview> visible =
        reviews.take(maxReviewsToShow).toList();
    final int total = totalReviews > 0 ? totalReviews : reviews.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              context.tr('product.customerReviews'),
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: <Widget>[
              Text(
                averageRating.toStringAsFixed(1),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RatingStars(rating: averageRating, size: 18, showValue: false),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('product.ratingsCount', <String, Object?>{
                      'count': MoneyFormatter.formatWhole(total),
                    }),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          for (int i = 0; i < visible.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: Spacing.xl),
            _ReviewTile(review: visible[i]),
          ],
          if (onViewAllTap != null && reviews.length > maxReviewsToShow) ...<Widget>[
            const SizedBox(height: Spacing.md),
            AppButton.secondary(
              label: context.tr('product.seeAllReviews', <String, Object?>{
                'count': MoneyFormatter.formatWhole(total),
              }),
              size: AppButtonSize.medium,
              onPressed: onViewAllTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewTile extends StatefulWidget {
  const _ReviewTile({required this.review});

  final CustomerReview review;

  @override
  State<_ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<_ReviewTile> {
  bool _expanded = false;

  String _relativeDate(BuildContext context, String raw) {
    final DateTime? date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final int days = DateTime.now().difference(date).inDays;
    if (days <= 0) return context.tr('common.today');
    if (days == 1) return context.tr('common.yesterday');
    if (days < 7) {
      return context.tr('common.daysAgo', <String, Object?>{'count': days});
    }
    final String locale = Localizations.localeOf(context).toLanguageTag();
    try {
      return DateFormat.yMMMd(locale).format(date);
    } catch (_) {
      return DateFormat.yMMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CustomerReview r = widget.review;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            RatingStars(
              rating: r.rating.toDouble(),
              size: 14,
              showValue: false,
            ),
            const Spacer(),
            Text(
              _relativeDate(context, r.reviewedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (r.content.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.xs),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: AnimatedSize(
              duration: AppMotion.fast,
              alignment: AlignmentDirectional.topStart,
              child: Text(
                r.content,
                maxLines: _expanded ? null : 4,
                overflow: _expanded ? null : TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ),
        ],
        if (r.images.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: r.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
              itemBuilder: (BuildContext context, int index) {
                return ClipRRect(
                  borderRadius: AppRadius.smAll,
                  child: AppNetworkImage(
                    url: r.images[index],
                    width: 72,
                    height: 72,
                    memCacheWidth:
                        (72 * MediaQuery.devicePixelRatioOf(context)).round(),
                    errorWidget: ColoredBox(
                      color: scheme.surfaceContainerHigh,
                      child: Icon(Icons.image_outlined, color: scheme.outline),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
