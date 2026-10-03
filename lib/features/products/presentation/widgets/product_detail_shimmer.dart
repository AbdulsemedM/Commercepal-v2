import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// Product page skeleton mirroring the loaded layout (square photo,
/// thumbnails, title, price, stock line, options, purchase bar).
class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double imageHeight = math.min(width, 520);

    return Semantics(
      label: context.tr('common.loading'),
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ShimmerLoading(
                    width: double.infinity,
                    height: imageHeight,
                    borderRadius: BorderRadius.zero,
                  ),
                  const SizedBox(height: Spacing.sm),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.gutter,
                      ),
                      itemCount: 5,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: Spacing.xs),
                      itemBuilder: (_, __) =>
                          const ShimmerLoading(width: 60, height: 60),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      Spacing.gutter,
                      Spacing.md,
                      Spacing.gutter,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ShimmerLoading(width: 90, height: 12),
                        SizedBox(height: Spacing.xs),
                        ShimmerLoading(width: double.infinity, height: 18),
                        SizedBox(height: 6),
                        ShimmerLoading(width: 220, height: 18),
                        SizedBox(height: Spacing.sm),
                        ShimmerLoading(width: 140, height: 14),
                        SizedBox(height: Spacing.md),
                        ShimmerLoading(width: 170, height: 30),
                        SizedBox(height: Spacing.sm),
                        ShimmerLoading(width: 100, height: 14),
                        SizedBox(height: Spacing.lg),
                        ShimmerLoading(width: 120, height: 14),
                        SizedBox(height: Spacing.sm),
                        Row(
                          children: <Widget>[
                            ShimmerLoading(width: 96, height: 44),
                            SizedBox(width: Spacing.xs),
                            ShimmerLoading(width: 96, height: 44),
                            SizedBox(width: Spacing.xs),
                            ShimmerLoading(width: 96, height: 44),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: context.commerce.border)),
            ),
            child: const SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(Spacing.gutter),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ShimmerLoading(
                        height: AppSizes.buttonLg,
                        borderRadius: AppRadius.pillAll,
                      ),
                    ),
                    SizedBox(width: Spacing.xs),
                    Expanded(
                      child: ShimmerLoading(
                        height: AppSizes.buttonLg,
                        borderRadius: AppRadius.pillAll,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
