import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/update/app_update_remote_config.dart';

/// Hero banner: pink → orange → gold gradient card with a marketplace
/// chip, headline, subtitle and an "Explore deals" call to action.
class BannerSection extends StatelessWidget {
  const BannerSection({super.key});

  static const LinearGradient _heroGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: <Color>[
      Color(0xFFE9146B),
      Color(0xFFF97316),
      Color(0xFFFBBF24),
    ],
    stops: <double>[0.0, 0.6, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    String promo = '';
    try {
      promo = AppUpdateRemoteConfig.homePromoBanner;
    } catch (_) {}
    final String subtitle = promo.isNotEmpty
        ? promo
        : 'Millions of products from every corner of the globe, delivered to your door.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
      decoration: BoxDecoration(
        gradient: _heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFE9146B).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // Globe line-art decoration
          Positioned(
            top: -12,
            right: -16,
            child: Icon(
              Icons.public,
              size: 130,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'GLOBAL MARKETPLACE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'Shop the World',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                FilledButton(
                  onPressed: () => context.push(AppRoutes.productSearch),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF17162B),
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Explore deals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
