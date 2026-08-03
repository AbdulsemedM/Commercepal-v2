import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';

class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: Spacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: _buildShimmerBox(
                scheme,
                width: double.infinity,
                height: 300,
                borderRadius: AppDecorations.radiusLg,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildShimmerBox(
                    scheme,
                    width: 8,
                    height: 8,
                    borderRadius: 999,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildShimmerBox(
                    scheme,
                    width: double.infinity,
                    height: 22,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: Spacing.xs),
                  _buildShimmerBox(
                    scheme,
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: 22,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildShimmerBox(
                    scheme,
                    width: 150,
                    height: 30,
                    borderRadius: 8,
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildShimmerBox(
                    scheme,
                    width: 120,
                    height: 18,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Wrap(
                    spacing: Spacing.sm,
                    children: <Widget>[
                      _buildShimmerBox(
                        scheme,
                        width: 130,
                        height: 52,
                        borderRadius: 14,
                      ),
                      _buildShimmerBox(
                        scheme,
                        width: 130,
                        height: 52,
                        borderRadius: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: <Widget>[
                      _buildShimmerBox(
                        scheme,
                        width: 80,
                        height: 26,
                        borderRadius: 999,
                      ),
                      const SizedBox(width: Spacing.xs),
                      _buildShimmerBox(
                        scheme,
                        width: 56,
                        height: 26,
                        borderRadius: 999,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildShimmerBox(
                    scheme,
                    width: double.infinity,
                    height: 88,
                    borderRadius: AppDecorations.radiusMd,
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildShimmerBox(
                    scheme,
                    width: double.infinity,
                    height: 180,
                    borderRadius: AppDecorations.radiusMd,
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildShimmerBox(
                          scheme,
                          width: double.infinity,
                          height: 40,
                          borderRadius: 999,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: _buildShimmerBox(
                          scheme,
                          width: double.infinity,
                          height: 40,
                          borderRadius: 999,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(
    ColorScheme scheme, {
    required double width,
    required double height,
    required double borderRadius,
  }) {
    final Color base = scheme.surfaceContainerHighest;
    final Color highlight = scheme.surface;
    final Color fill = scheme.surfaceContainerLow;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
