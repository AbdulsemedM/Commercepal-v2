import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';

class BannerSection extends StatelessWidget {
  const BannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
      height: 180,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/banner.png',
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 60),
                  ),
                );
              },
        ),
      ),
    );
  }
}
