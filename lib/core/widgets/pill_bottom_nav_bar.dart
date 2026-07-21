import 'package:commercepal/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:commercepal/services/localization_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color selectedColor = activeColor ?? AppColors.pink;
    final Color inactiveColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    final Color barColor = isDark ? theme.colorScheme.surface : AppColors.cream;

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

    return Container(
      decoration: BoxDecoration(
        color: barColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List<Widget>.generate(items.length, (int index) {
              final bool isSelected = index == currentIndex;
              final _NavItemData item = items[index];
              final int count =
                  (badgeCounts != null && index < badgeCounts!.length)
                  ? badgeCounts![index]
                  : 0;
              return Expanded(
                child: _NavItem(
                  icon: isSelected ? item.selectedIcon : item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  selectedColor: selectedColor,
                  inactiveColor: inactiveColor,
                  badgeCount: count,
                  onTap: () => onTap(index),
                ),
              );
            }),
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
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.inactiveColor,
    required this.onTap,
    required this.badgeCount,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color inactiveColor;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final Color contentColor = isSelected ? selectedColor : inactiveColor;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Icon(icon, color: contentColor, size: 24),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: _Badge(count: badgeCount),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: contentColor,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.labelSmall!.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      height: 1,
      fontSize: 10,
    );

    final String text = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: AppColors.pink,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(text, style: textStyle),
    );
  }
}
