import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/tokens.dart';
import 'package:commercepal/core/widgets/app_badge.dart';
import 'package:commercepal/services/localization_service.dart';

/// Dashboard page indexes. Kept stable because many screens switch tabs by
/// number (cart is 2, profile is 3); Orders and Saved were added after them.
class DashboardTab {
  DashboardTab._();

  static const int home = 0;
  static const int shop = 1;
  static const int cart = 2;
  static const int account = 3;
  static const int orders = 4;
  static const int saved = 5;

  static const int count = 6;
}

/// Main tab bar: a floating dark pill with five always-labelled tabs
/// (Home, Shop, Orders, Saved, Account). The cart opens from the header bag
/// icon and the slide-in cart, so it is not a tab.
class PillBottomNavBar extends StatelessWidget {
  const PillBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.badgeCounts,
    this.activeColor,
  });

  /// The dashboard page index (see [DashboardTab]).
  final int currentIndex;

  /// Called with a dashboard page index (see [DashboardTab]).
  final ValueChanged<int> onTap;

  /// Badge per dashboard page index.
  final List<int>? badgeCounts;
  final Color? activeColor;

  static const double _barHeight = 64;
  static const Color _pill = Color(0xFF141416);

  @override
  Widget build(BuildContext context) {
    final List<_NavItemData> items = <_NavItemData>[
      _NavItemData(
        page: DashboardTab.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: LocalizationService.t(context, 'nav.home'),
      ),
      _NavItemData(
        page: DashboardTab.shop,
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
        label: LocalizationService.t(context, 'nav.shop'),
      ),
      _NavItemData(
        page: DashboardTab.orders,
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
        label: LocalizationService.t(context, 'nav.orders'),
      ),
      _NavItemData(
        page: DashboardTab.saved,
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
        label: LocalizationService.t(context, 'nav.saved'),
      ),
      _NavItemData(
        page: DashboardTab.account,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: LocalizationService.t(context, 'nav.account'),
      ),
    ];

    final Color selectedColor = activeColor ?? Colors.white;
    final Color inactiveColor = Colors.white.withValues(alpha: 0.55);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: Spacing.xs),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Spacing.sm, Spacing.xxs, Spacing.sm, Spacing.xxs),
        child: Container(
          height: _barHeight,
          decoration: BoxDecoration(
            color: _pill,
            borderRadius: BorderRadius.circular(_barHeight / 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 6)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    data: items[i],
                    index: i,
                    total: items.length,
                    isSelected: items[i].page == currentIndex,
                    selectedColor: selectedColor,
                    inactiveColor: inactiveColor,
                    badgeCount: (badgeCounts != null && items[i].page < badgeCounts!.length)
                        ? badgeCounts![items[i].page]
                        : 0,
                    onTap: () {
                      if (items[i].page != currentIndex) {
                        HapticFeedback.selectionClick();
                      }
                      onTap(items[i].page);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.page,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final int page;
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
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
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
        radius: 32,
        highlightColor: Colors.white10,
        splashColor: Colors.white12,
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
                  size: 23,
                ),
              ),
            ),
            const SizedBox(height: 3),
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
