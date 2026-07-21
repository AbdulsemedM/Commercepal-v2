import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    required this.cartCount,
    required this.userInitials,
    required this.onSearchSubmitted,
    this.onLogoTap,
    this.onCartTap,
    this.onProfileTap,
    this.hasNotification = false,
    this.searchPlaceholder,
    this.onSearchTap,
    this.additionalActions,
  });

  final int cartCount;
  final String userInitials;
  final String? Function(String) onSearchSubmitted;
  final VoidCallback? onLogoTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;
  final bool hasNotification;
  final String? searchPlaceholder;
  final VoidCallback? onSearchTap;
  /// Shown after the search field and before the cart icon (e.g. overflow menu).
  final List<Widget>? additionalActions;

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight + 20);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String placeholder =
        searchPlaceholder ??
        LocalizationService.t(context, 'appBar.searchPlaceholder');
    final Color barColor = isDark ? scheme.surface : AppColors.cream;
    final Color searchFill = isDark ? scheme.surfaceContainerLow : Colors.white;
    final Color searchSecondary = scheme.onSurfaceVariant;

    return Container(
      color: barColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: Spacing.md,
            right: Spacing.md,
            top: Spacing.md,
            bottom: Spacing.md,
          ),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: onLogoTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.navy,
                          size: 26,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: InkWell(
                  onTap: onSearchTap,
                  borderRadius: BorderRadius.circular(23),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: searchFill,
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      enabled: onSearchTap == null,
                      decoration: InputDecoration(
                        hintText: placeholder,
                        hintStyle: TextStyle(
                          color: searchSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.search,
                            color: searchSecondary,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Spacing.xs,
                          vertical: Spacing.sm,
                        ),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurface,
                      ),
                      onSubmitted: (String value) {
                        onSearchSubmitted(value);
                      },
                    ),
                  ),
                ),
              ),
              if (additionalActions != null && additionalActions!.isNotEmpty) ...[
                const SizedBox(width: Spacing.xs),
                ...additionalActions!,
              ],
              const SizedBox(width: Spacing.sm),
              InkWell(
                onTap: onCartTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: searchFill,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: isDark ? scheme.onSurface : AppColors.navy,
                        size: 24,
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: -12,
                          top: -14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.pink,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              cartCount > 99 ? '99+' : '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.pink,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            userInitials.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      if (hasNotification)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: barColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
