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
    final Color selectedColor = activeColor ?? AppColors.primary;
    final Color inactiveColor = theme.colorScheme.onSurfaceVariant.withOpacity(
      0.5,
    );

    final List<_NavItemData> items = <_NavItemData>[
      _NavItemData(
        icon: Icons.home_rounded,
        label: LocalizationService.t(context, 'nav.home'),
      ),
      _NavItemData(
        icon: Icons.dashboard_rounded,
        label: LocalizationService.t(context, 'nav.categories'),
      ),
      _NavItemData(
        icon: Icons.shopping_cart_rounded,
        label: LocalizationService.t(context, 'nav.cart'),
      ),
      _NavItemData(
        icon: Icons.person_rounded,
        label: LocalizationService.t(context, 'nav.profile'),
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.35),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(items.length, (int index) {
            final bool isSelected = index == currentIndex;
            final _NavItemData item = items[index];
            final int count =
                (badgeCounts != null && index < badgeCounts!.length)
                ? badgeCounts![index]
                : 0;
            return _NavItem(
              icon: item.icon,
              label: item.label,
              isSelected: isSelected,
              selectedColor: selectedColor,
              inactiveColor: inactiveColor,
              badgeCount: count,
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});
  final IconData icon;
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
    final TextStyle labelStyle = Theme.of(context).textTheme.labelLarge!
        .copyWith(color: Colors.white, fontWeight: FontWeight.w700);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Icon(icon, color: isSelected ? Colors.white : inactiveColor),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: _Badge(count: badgeCount),
                  ),
              ],
            ),
            if (isSelected) ...<Widget>[
              const SizedBox(width: 8),
              Text(label, style: labelStyle),
            ],
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
    );

    final String text = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(text, style: textStyle),
    );
  }
}
