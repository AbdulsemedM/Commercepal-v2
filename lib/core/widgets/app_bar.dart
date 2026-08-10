import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    required this.cartCount,
    required this.onSearchSubmitted,
    this.onLogoTap,
    this.onCartTap,
    this.searchPlaceholder,
    this.onSearchTap,
    this.showVisualSearch = true,
    this.onVisualSearchTap,
    this.additionalActions,
  });

  final int cartCount;
  final String? Function(String) onSearchSubmitted;
  final VoidCallback? onLogoTap;
  final VoidCallback? onCartTap;
  final String? searchPlaceholder;
  final VoidCallback? onSearchTap;
  /// Camera shortcut inside the search field (defaults to visual search route).
  final bool showVisualSearch;
  final VoidCallback? onVisualSearchTap;
  /// Shown after the search field and before the cart icon (e.g. overflow menu).
  final List<Widget>? additionalActions;

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight + 36);
  }

  void _openVisualSearch(BuildContext context) {
    if (onVisualSearchTap != null) {
      onVisualSearchTap!();
      return;
    }
    context.push(AppRoutes.visualSearch);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String placeholder =
        searchPlaceholder ??
        LocalizationService.t(context, 'appBar.searchPlaceholder');
    final Color barColor = isDark ? scheme.surface : AppColors.primary;
    final Color searchFill = isDark ? scheme.surfaceContainerLow : Colors.white;
    final Color searchSecondary = scheme.onSurfaceVariant;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return ColoredBox(
      color: scaffoldBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Container(
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm + 2,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: onLogoTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return const Icon(
                            Icons.bolt_rounded,
                            color: AppColors.navy,
                            size: 22,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: searchFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: onSearchTap,
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 4,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    color: searchSecondary,
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    enabled: onSearchTap == null,
                                    decoration: InputDecoration(
                                      hintText: placeholder,
                                      hintStyle: TextStyle(
                                        color: searchSecondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: scheme.onSurface,
                                    ),
                                    onSubmitted: (String value) {
                                      onSearchSubmitted(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (showVisualSearch)
                          IconButton(
                            tooltip: 'Visual search',
                            onPressed: () => _openVisualSearch(context),
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              color: searchSecondary,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                ),
                if (additionalActions != null &&
                    additionalActions!.isNotEmpty) ...[
                  const SizedBox(width: Spacing.xs),
                  ...additionalActions!,
                ],
                const SizedBox(width: Spacing.sm),
                InkWell(
                  onTap: onCartTap,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: isDark ? scheme.onSurface : Colors.white,
                          size: 24,
                        ),
                        if (cartCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
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
                                  fontSize: 10,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
