import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme/commerce_colors.dart';
import '../theme/tokens.dart';

/// Skeleton block with a sweeping highlight. Theme-aware (light/dark).
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1300),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommerceColors c = context.commerce;
    // Respect the OS "reduce motion" setting with a static placeholder.
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final BorderRadius radius = widget.borderRadius ?? AppRadius.smAll;

    if (reduceMotion) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: c.skeletonBase, borderRadius: radius),
      );
    }

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double t = _controller.value * 2 - 0.5;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  c.skeletonBase,
                  c.skeletonHighlight,
                  c.skeletonBase,
                ],
                stops: <double>[t - 0.35, t, t + 0.35]
                    .map((double s) => s.clamp(0.0, 1.0))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Placeholder shaped like a product tile.
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.commerce.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AspectRatio(
            aspectRatio: 1,
            child: ShimmerLoading(borderRadius: BorderRadius.zero),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.xs + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const ShimmerLoading(height: 12, width: double.infinity),
                const SizedBox(height: 6),
                const ShimmerLoading(height: 12, width: 96),
                const SizedBox(height: Spacing.xs + 2),
                ShimmerLoading(
                  height: 18,
                  width: 72,
                  borderRadius: AppRadius.xsAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shaped like a list row (orders, addresses, notifications).
class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({super.key, this.leadingSize = 56});

  final double leadingSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.gutter,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: <Widget>[
          ShimmerLoading(
            width: leadingSize,
            height: leadingSize,
            borderRadius: AppRadius.smAll,
          ),
          const SizedBox(width: Spacing.sm),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerLoading(height: 13, width: double.infinity),
                SizedBox(height: 8),
                ShimmerLoading(height: 12, width: 140),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
