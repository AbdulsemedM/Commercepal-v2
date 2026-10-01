import 'package:flutter/material.dart';

import '../theme/commerce_colors.dart';
import '../theme/tokens.dart';

enum AppBadgeTone { brand, deal, success, warning, info, neutral, error }

enum AppBadgeSize { small, medium }

/// Compact status / merchandising label ("-20%", "Best seller", "Paid").
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.size = AppBadgeSize.small,
    this.icon,
    this.solid,
  });

  final String label;
  final AppBadgeTone tone;
  final AppBadgeSize size;
  final IconData? icon;

  /// Filled (true) or soft tinted (false). Defaults to filled for deals.
  final bool? solid;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors c = context.commerce;
    final bool filled = solid ?? tone == AppBadgeTone.deal;

    final (Color strong, Color onStrong, Color soft, Color onSoft) =
        switch (tone) {
      AppBadgeTone.brand => (
          scheme.primary,
          scheme.onPrimary,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      AppBadgeTone.deal => (
          c.deal,
          c.onDeal,
          c.dealContainer,
          c.onDealContainer,
        ),
      AppBadgeTone.success => (
          c.success,
          Colors.white,
          c.successContainer,
          c.onSuccessContainer,
        ),
      AppBadgeTone.warning => (
          c.warning,
          Colors.white,
          c.warningContainer,
          c.onWarningContainer,
        ),
      AppBadgeTone.info => (
          c.info,
          Colors.white,
          c.infoContainer,
          c.onInfoContainer,
        ),
      AppBadgeTone.error => (
          scheme.error,
          scheme.onError,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
      AppBadgeTone.neutral => (
          scheme.inverseSurface,
          scheme.onInverseSurface,
          scheme.surfaceContainerHigh,
          scheme.onSurfaceVariant,
        ),
    };

    final bool small = size == AppBadgeSize.small;
    final Color fg = filled ? onStrong : onSoft;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: filled ? strong : soft,
        borderRadius: AppRadius.xsAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: small ? 11 : 13, color: fg),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: fg,
                fontSize: small ? 10.5 : 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small numeric counter for icons (cart, notifications). Hidden at zero.
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    required this.child,
    this.max = 99,
  });

  final int count;
  final Widget child;
  final int max;

  @override
  Widget build(BuildContext context) {
    final CommerceColors c = context.commerce;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        if (count > 0)
          PositionedDirectional(
            end: -7,
            top: -5,
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              transitionBuilder: (Widget w, Animation<double> a) =>
                  ScaleTransition(scale: a, child: w),
              child: Container(
                key: ValueKey<int>(count),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.deal,
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  count > max ? '$max+' : '$count',
                  style: TextStyle(
                    color: c.onDeal,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
