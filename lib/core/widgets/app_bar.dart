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
    // Height will be calculated dynamically based on status bar + content
    return const Size.fromHeight(kToolbarHeight + 20);
  }

  @override
  Widget build(BuildContext context) {
    final String placeholder =
        searchPlaceholder ??
        LocalizationService.t(context, 'appBar.searchPlaceholder');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
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
              // Logo on the left
              InkWell(
                onTap: onLogoTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 40,
                    height: 40,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return const SizedBox(width: 40, height: 40);
                        },
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              // Search bar in the center
              Expanded(
                child: InkWell(
                  onTap: onSearchTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      enabled: onSearchTap == null,
                      decoration: InputDecoration(
                        hintText: placeholder,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.search,
                            color: Colors.grey.shade500,
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
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
              // Shopping cart with badge
              InkWell(
                onTap: onCartTap,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 8,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 10,
                              minHeight: 10,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
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
              // User avatar with notification dot
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userInitials.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      if (hasNotification)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
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
