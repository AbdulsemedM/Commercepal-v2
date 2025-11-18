import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';

class ProductImageSection extends StatelessWidget {
  const ProductImageSection({
    super.key,
    required this.images,
    required this.selectedImageIndex,
    required this.onImageSelected,
  });

  final List<String> images;
  final int selectedImageIndex;
  final ValueChanged<int> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Main product image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: images.isNotEmpty && images[selectedImageIndex].isNotEmpty
                    ? Image.asset(
                        images[selectedImageIndex],
                        fit: BoxFit.contain,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          // Thumbnail images
          SizedBox(
            width: 80,
            child: ListView.builder(
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                final bool isSelected = index == selectedImageIndex;
                return GestureDetector(
                  onTap: () => onImageSelected(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: Spacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: images[index].isNotEmpty
                            ? Image.asset(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (
                                  BuildContext context,
                                  Object error,
                                  StackTrace? stackTrace,
                                ) {
                                  return _buildThumbnailPlaceholder();
                                },
                              )
                            : _buildThumbnailPlaceholder(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 30,
        ),
      ),
    );
  }
}

