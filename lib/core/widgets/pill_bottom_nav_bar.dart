import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:commercepal/core/theme/commerce_colors.dart';
import 'package:commercepal/core/theme/tokens.dart';
import 'package:commercepal/core/widgets/app_badge.dart';
import 'package:commercepal/services/localization_service.dart';

/// Main tab bar: flat surface, hairline top border and an animated indicator
/// above the selected tab.
class PillBottomNavBar extends StatelessWidget {
  const PillBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.badgeCounts,
    this.activeColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<int>? badgeCounts;
  final Color? activeColor;

  static const double _barHeight = 60;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color selectedColor = activeColor ?? scheme.primary;
    final Color inactiveColor = scheme.onSurfaceVariant;

    final List<_NavItemData> items = <_NavItemData>[
      _NavItemData(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: LocalizationService.t(context, 'nav.home'),
      ),
      _NavItemData(
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
        label: LocalizationService.t(context, 'nav.categories'),
      ),
      _NavItemData(
        icon: Icons.shopping_cart_outlined,
        selectedIcon: Icons.shopping_cart_rounded,
        label: LocalizationService.t(context, 'nav.cart'),
      ),
      _NavItemData(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: LocalizationService.t(context, 'nav.profile'),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: context.commerce.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double slot = constraints.maxWidth / items.length;
              const double indicatorWidth = 32;
              final bool rtl = Directionality.of(context) == TextDirection.rtl;
              final int visualIndex =
                  rtl ? items.length - 1 - currentIndex : currentIndex;
              return Stack(
                children: <Widget>[
                  AnimatedPositioned(
                    duration: AppMotion.medium,
                    curve: AppMotion.emphasized,
                    top: 0,
                    left: slot * visualIndex + (slot - indicatorWidth) / 2,
                    child: Container(
                      width: indicatorWidth,
                      height: 3,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List<Widget>.generate(items.length, (int i) {
                      final _NavItemData item = items[i];
                      final int count =
                          (badgeCounts != null && i < badgeCounts!.length)
                              ? badgeCounts![i]
                              : 0;
                      return Expanded(
                        child: _NavItem(
                          data: item,
                          index: i,
                          total: items.length,
                          isSelected: i == currentIndex,
                          selectedColor: selectedColor,
                          inactiveColor: inactiveColor,
                          badgeCount: count,
                          onTap: () {
                            if (i != currentIndex) {
                              HapticFeedback.selectionClick();
                            }
                            onTap(i);
                          },
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.index,
    required this.total,
    required this.isSelected,
    required this.selectedColor,
    required this.inactiveColor,
    required this.onTap,
    required this.badgeCount,
  });

  final _NavItemData data;
  final int index;
  final int total;
  final bool isSelected;
  final Color selectedColor;
  final Color inactiveColor;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? selectedColor : inactiveColor;
    final TextStyle? labelStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            );

    return Semantics(
      selected: isSelected,
      button: true,
      label: badgeCount > 0 ? '${data.label}, $badgeCount' : data.label,
      hint: '${index + 1}/$total',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CountBadge(
              count: badgeCount,
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Icon(
                  isSelected ? data.selectedIcon : data.icon,
                  key: ValueKey<bool>(isSelected),
                  color: color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ],
        ),
      ),
    );
  }
}
