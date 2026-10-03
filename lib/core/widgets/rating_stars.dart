import 'package:flutter/material.dart';

import '../../services/localization_service.dart';
import '../theme/commerce_colors.dart';
import '../theme/typography.dart';

/// Star rating with optional numeric value and review count, e.g.
/// ★★★★☆ 4.3 (1.2k).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 14,
    this.showValue = true,
    this.compact = false,
  });

  /// 0–5. Values outside the range are clamped.
  final double rating;
  final int? reviewCount;
  final double size;
  final bool showValue;

  /// Single star + value — for tight product tiles.
  final bool compact;

  /// 1234 → "1.2k", 2500000 → "2.5M".
  static String formatCount(int n) {
    if (n >= 1000000) return '${_trim(n / 1000000)}M';
    if (n >= 1000) return '${_trim(n / 1000)}k';
    return '$n';
  }

  static String _trim(double v) {
    final String s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  @override
  Widget build(BuildContext context) {
    final CommerceColors c = context.commerce;
    final ThemeData theme = Theme.of(context);
    final double r = rating.clamp(0, 5).toDouble();

    final TextStyle valueStyle =
        (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
      fontSize: size - 1.5,
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      fontFeatures: AppTypography.tabularFigures,
    );
    final TextStyle countStyle = valueStyle.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w400,
    );

    final List<Widget> stars = compact
        ? <Widget>[Icon(Icons.star_rounded, size: size + 2, color: c.rating)]
        : List<Widget>.generate(5, (int i) {
            final double fill = (r - i).clamp(0, 1).toDouble();
            return _Star(
              fill: fill,
              size: size,
              color: c.rating,
              empty: c.ratingEmpty,
            );
          });

    final String label = context.tr('rating.semantic', <String, Object?>{
      'rating': r.toStringAsFixed(1),
      'count': reviewCount ?? 0,
    });

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ...stars,
          if (showValue) ...<Widget>[
            const SizedBox(width: 4),
            Text(r.toStringAsFixed(1), style: valueStyle),
          ],
          if (reviewCount != null && reviewCount! > 0) ...<Widget>[
            const SizedBox(width: 3),
            Text('(${formatCount(reviewCount!)})', style: countStyle),
          ],
        ],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({
    required this.fill,
    required this.size,
    required this.color,
    required this.empty,
  });

  final double fill;
  final double size;
  final Color color;
  final Color empty;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: <Widget>[
          Icon(Icons.star_rounded, size: size, color: empty),
          ClipRect(
            clipper: _FractionClipper(fill, rtl: rtl),
            child: Icon(Icons.star_rounded, size: size, color: color),
          ),
        ],
      ),
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  const _FractionClipper(this.fraction, {required this.rtl});

  final double fraction;
  final bool rtl;

  @override
  Rect getClip(Size size) {
    final double w = size.width * fraction;
    return rtl
        ? Rect.fromLTWH(size.width - w, 0, w, size.height)
        : Rect.fromLTWH(0, 0, w, size.height);
  }

  @override
  bool shouldReclip(_FractionClipper old) =>
      old.fraction != fraction || old.rtl != rtl;
}
