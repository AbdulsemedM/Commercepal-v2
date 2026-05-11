import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:commercepal/core/constants/spacing.dart';

class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.sm),
          // Image Gallery Shimmer
          _buildImageGalleryShimmer(scheme),
          const SizedBox(height: Spacing.md),
          
          // Product Info Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                _buildShimmerBox(
                  scheme,
                  width: double.infinity,
                  height: 24,
                  borderRadius: 4,
                ),
                const SizedBox(height: Spacing.xs),
                _buildShimmerBox(
                  scheme,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 24,
                  borderRadius: 4,
                ),
                const SizedBox(height: Spacing.md),
                
                // Rating shimmer
                Row(
                  children: [
                    _buildShimmerBox(scheme, width: 80, height: 16, borderRadius: 4),
                    const SizedBox(width: Spacing.sm),
                    _buildShimmerBox(scheme, width: 100, height: 16, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                
                // Price shimmer
                _buildShimmerBox(scheme, width: 120, height: 32, borderRadius: 6),
                const SizedBox(height: Spacing.sm),
                _buildShimmerBox(scheme, width: 150, height: 16, borderRadius: 4),
                const SizedBox(height: Spacing.lg),
                
                // Product code and category shimmer
                _buildInfoRowShimmer(scheme),
                const SizedBox(height: Spacing.xs),
                _buildInfoRowShimmer(scheme),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
          
          // Variant Selector Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(scheme, width: 100, height: 20, borderRadius: 4),
                const SizedBox(height: Spacing.sm),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                    itemBuilder: (_, index) => _buildShimmerBox(
                      scheme,
                      width: 80,
                      height: 40,
                      borderRadius: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          
          // Description Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(scheme, width: 120, height: 20, borderRadius: 4),
                const SizedBox(height: Spacing.sm),
                _buildShimmerBox(
                  scheme,
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: Spacing.xs),
                _buildShimmerBox(
                  scheme,
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: Spacing.xs),
                _buildShimmerBox(
                  scheme,
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 16,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          
          // Specifications Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(scheme, width: 140, height: 20, borderRadius: 4),
                const SizedBox(height: Spacing.sm),
                _buildSpecificationRowShimmer(scheme),
                const SizedBox(height: Spacing.xs),
                _buildSpecificationRowShimmer(scheme),
                const SizedBox(height: Spacing.xs),
                _buildSpecificationRowShimmer(scheme),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          
          // Reviews Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(scheme, width: 120, height: 20, borderRadius: 4),
                    _buildShimmerBox(scheme, width: 60, height: 16, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _buildReviewCardShimmer(scheme),
                const SizedBox(height: Spacing.sm),
                _buildReviewCardShimmer(scheme),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          
          // Recommended Products Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(scheme, width: 180, height: 20, borderRadius: 4),
                const SizedBox(height: Spacing.md),
                SizedBox(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                    itemBuilder: (_, index) => _buildProductCardShimmer(scheme),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }

  Widget _buildImageGalleryShimmer(ColorScheme scheme) {
    final Color base = scheme.surfaceContainerHighest;
    final Color highlight = scheme.surface;
    final Color fill = scheme.surfaceContainerLow;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 350,
            color: fill,
          ),
          const SizedBox(height: Spacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildInfoRowShimmer(ColorScheme scheme) {
    final Color base = scheme.surfaceContainerHighest;
    final Color highlight = scheme.surface;
    final Color fill = scheme.surfaceContainerLow;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationRowShimmer(ColorScheme scheme) {
    final Color base = scheme.surfaceContainerHighest;
    final Color highlight = scheme.surface;
    final Color fill = scheme.surfaceContainerLow;
    final Color inner = scheme.outlineVariant;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.sm,
          horizontal: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: inner,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: inner,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCardShimmer(ColorScheme scheme) {
    final Color base = scheme.surfaceContainerHighest;
    final Color highlight = scheme.surface;
    final Color fill = scheme.surfaceContainerLow;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCardShimmer(ColorScheme scheme) {
    final Color base = scheme.surfaceContainerHighest;
    final Color highlight = scheme.surface;
    final Color fill = scheme.surfaceContainerLow;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 130,
                    height: 14,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
