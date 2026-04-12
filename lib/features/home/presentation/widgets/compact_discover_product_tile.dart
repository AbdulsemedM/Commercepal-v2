import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 58,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(9),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => _placeholder(),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return ColoredBox(
                                color: AppColors.lightGrey,
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : _placeholder(),
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
                                color: Colors.grey.shade800,
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
                              color: Colors.grey.shade400,
                              fontSize: 8,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: originalPrice != null
                                      ? AppColors.error
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            if (discountPercentage != null &&
                                discountPercentage! > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.error.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '-$discountPercentage%',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: AppColors.error,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
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

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.lightGrey,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade400,
        size: 22,
      ),
    );
  }
}
