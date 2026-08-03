import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/widgets/app_network_image.dart';

/// Dense tile for 5-column home discover grids; taps navigate to product detail.
/// Layout is strictly bounded so titles/prices cannot overflow the grid cell.
class CompactDiscoverProductTile extends StatelessWidget {
  const CompactDiscoverProductTile({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
  });

  final String productId;
  final String imageUrl;
  final String title;
  final String price;
  final String? originalPrice;
  final int? discountPercentage;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (productId.isNotEmpty) {
              context.push(
                '${AppRoutes.productDetail}?id=${Uri.encodeComponent(productId)}',
              );
            }
          },
          child: Ink(
            decoration: BoxDecoration(
              color: isDark ? scheme.surfaceContainerLow : Colors.white,
              borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
              boxShadow: AppDecorations.softCardShadow(scheme.shadow),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 58,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDecorations.radiusSm - 1),
                        ),
                        child: imageUrl.isNotEmpty
                            ? AppNetworkImage(
                                url: imageUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: (80 *
                                        MediaQuery.devicePixelRatioOf(context))
                                    .round(),
                                placeholder: ColoredBox(
                                  color: scheme.surfaceContainerHighest
                                      .withValues(alpha: 0.6),
                                ),
                                errorWidget: _placeholder(context),
                              )
                            : _placeholder(context),
                      ),
                      if (discountPercentage != null && discountPercentage! > 0)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-$discountPercentage%',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 42,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.xs,
                      4,
                      Spacing.xs,
                      4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? scheme.onSurface
                                    : AppColors.navy,
                                height: 1.15,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        if (originalPrice != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            originalPrice!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 8,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest.withOpacity(0.6),
      child: Icon(
        Icons.image_outlined,
        color: scheme.onSurfaceVariant,
        size: 22,
      ),
    );
  }
}
