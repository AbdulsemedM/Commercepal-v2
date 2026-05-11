import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/update/app_update_remote_config.dart';

class BannerSection extends StatelessWidget {
  const BannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    String promo = '';
    try {
      promo = AppUpdateRemoteConfig.homePromoBanner;
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
      height: 180,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              'assets/images/banner.png',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Container(
                      color: scheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          color: scheme.onSurfaceVariant,
                          size: 60,
                        ),
                      ),
                    );
                  },
            ),
            if (promo.isNotEmpty)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  color: Colors.black54,
                  child: Text(
                    promo,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
