import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import '../../data/models/product_image.dart';
import '../screen/product_image_viewer_screen.dart';

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
  late int _selectedIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        child: _buildMainFrame(child: _buildPlaceholder()),
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: _buildMainFrame(
            child: Stack(
              children: <Widget>[
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final ProductImage image = widget.images[index];
                    return GestureDetector(
                      onTap: () {
                        final List<String> urls = widget.images
                            .map((ProductImage img) => img.main)
                            .where((String u) => u.isNotEmpty)
                            .toList();
                        if (urls.isEmpty) return;
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ProductImageViewerScreen(
                              imageUrls: urls,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        image.main,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return _buildPlaceholder();
                        },
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                if (widget.onToggleWishlist != null)
                  Positioned(
                    top: Spacing.sm,
                    right: Spacing.sm,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onToggleWishlist,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            widget.isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              widget.images.length,
              (int index) {
                final bool active = index == _selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 18 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: active ? AppColors.primary : Colors.grey[300],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount: widget.images.length,
              itemBuilder: (BuildContext context, int index) {
                final ProductImage image = widget.images[index];
                final bool isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 64,
                    margin: const EdgeInsets.only(right: Spacing.xs),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 2.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        image.thumbnail.isNotEmpty
                            ? image.thumbnail
                            : image.main,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                            ),
                          );
                        },
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

  Widget _buildMainFrame({required Widget child}) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 72,
        color: Colors.white54,
      ),
    );
  }
}
