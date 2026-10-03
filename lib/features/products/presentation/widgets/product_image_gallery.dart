import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../data/models/product_image.dart';
import '../screen/product_image_viewer_screen.dart';

/// Full-bleed product photos with page counter, wishlist toggle and
/// thumbnail strip. Tap opens the zoomable viewer.
class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.isInWishlist = false,
    this.onToggleWishlist,
  });

  final List<ProductImage> images;
  final int initialIndex;
  final bool isInWishlist;
  final VoidCallback? onToggleWishlist;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late int _selectedIndex = widget.initialIndex;
  late final PageController _pageController =
      PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openViewer(int index) {
    final List<String> urls = widget.images
        .map((ProductImage img) => img.main.isNotEmpty ? img.main : img.thumbnail)
        .where((String u) => u.isNotEmpty)
        .toList();
    if (urls.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductImageViewerScreen(
          imageUrls: urls,
          initialIndex: index.clamp(0, urls.length - 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final double width = MediaQuery.sizeOf(context).width;
    // Square on phones; capped so tablets don't get a giant image.
    final double height = math.min(width, 520);
    final int cacheWidth =
        (math.min(width, 720) * MediaQuery.devicePixelRatioOf(context)).round();
    final int count = widget.images.length;

    final Widget placeholder = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.image_outlined, size: 64, color: scheme.outline),
      ),
    );

    return Column(
      children: <Widget>[
        Container(
          height: height,
          width: double.infinity,
          color: scheme.surface,
          child: Stack(
            children: <Widget>[
              if (count == 0)
                Positioned.fill(child: placeholder)
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: count,
                  onPageChanged: (int i) => setState(() => _selectedIndex = i),
                  itemBuilder: (BuildContext context, int index) {
                    final ProductImage image = widget.images[index];
                    final String url =
                        image.main.isNotEmpty ? image.main : image.thumbnail;
                    return Semantics(
                      image: true,
                      button: true,
                      label: context.tr('product.photoOf', <String, Object?>{
                        'index': index + 1,
                        'count': count,
                      }),
                      child: GestureDetector(
                        onTap: () => _openViewer(index),
                        child: AppNetworkImage(
                          url: url,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: height,
                          memCacheWidth: cacheWidth,
                          placeholder: const ShimmerLoading(
                            borderRadius: BorderRadius.zero,
                          ),
                          errorWidget: placeholder,
                        ),
                      ),
                    );
                  },
                ),
              if (count > 1)
                PositionedDirectional(
                  start: Spacing.sm,
                  bottom: Spacing.sm,
                  child: ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        '${_selectedIndex + 1}/$count',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontFeatures: AppTypography.tabularFigures,
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.onToggleWishlist != null)
                PositionedDirectional(
                  top: Spacing.sm,
                  end: Spacing.sm,
                  child: Material(
                    color: scheme.surface,
                    shape: const CircleBorder(),
                    elevation: 1,
                    shadowColor: Colors.black26,
                    child: IconButton(
                      tooltip: context.tr(
                        widget.isInWishlist
                            ? 'product.removeFromWishlist'
                            : 'product.addToWishlist',
                      ),
                      onPressed: widget.onToggleWishlist,
                      icon: AnimatedSwitcher(
                        duration: AppMotion.fast,
                        transitionBuilder: (Widget c, Animation<double> a) =>
                            ScaleTransition(scale: a, child: c),
                        child: Icon(
                          widget.isInWishlist
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey<bool>(widget.isInWishlist),
                          color: widget.isInWishlist
                              ? scheme.primary
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (count > 1) ...<Widget>[
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
              itemBuilder: (BuildContext context, int index) {
                final ProductImage image = widget.images[index];
                final bool selected = index == _selectedIndex;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: context.tr('product.photoOf', <String, Object?>{
                    'index': index + 1,
                    'count': count,
                  }),
                  child: GestureDetector(
                    onTap: () => _pageController.animateToPage(
                      index,
                      duration: AppMotion.medium,
                      curve: AppMotion.standard,
                    ),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      width: 60,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: AppRadius.smAll,
                        border: Border.all(
                          color: selected
                              ? scheme.primary
                              : context.commerce.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.xsAll,
                        child: AppNetworkImage(
                          url: image.thumbnail.isNotEmpty
                              ? image.thumbnail
                              : image.main,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          memCacheWidth:
                              (60 * MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                          errorWidget: placeholder,
                        ),
                      ),
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
