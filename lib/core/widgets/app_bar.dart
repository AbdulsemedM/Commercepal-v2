import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/commerce_colors.dart';
import 'package:commercepal/core/theme/tokens.dart';
import 'package:commercepal/core/widgets/app_badge.dart';
import 'package:commercepal/services/localization_service.dart';

/// Search-first brand header: a full-bleed band with logo (or back button),
/// search field with visual-search shortcut, optional actions and cart.
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
    this.showBackButton,
  });

  /// Height of the bar below the status bar.
  static const double barHeight = 64;

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

  /// Shows a back arrow (calling [onLogoTap], or popping) instead of the
  /// logo. Defaults to true when the current route can pop.
  final bool? showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  void _openVisualSearch(BuildContext context) {
    if (onVisualSearchTap != null) {
      onVisualSearchTap!();
      return;
    }
    context.push(AppRoutes.visualSearch);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors c = context.commerce;
    final bool isDark = theme.brightness == Brightness.dark;
    final String placeholder = searchPlaceholder ??
        LocalizationService.t(context, 'appBar.searchPlaceholder');
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;
    final bool back = showBackButton ?? canPop;

    final Color searchFill =
        isDark ? scheme.surfaceContainerHigh : Colors.white;
    final Color searchIcon = scheme.onSurfaceVariant;

    final Widget leading = back
        ? IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onLogoTap ?? () => Navigator.of(context).maybePop(),
            // Mirrors automatically in RTL.
            icon: Icon(Icons.arrow_back_rounded, color: c.onHeader),
          )
        : Semantics(
            button: onLogoTap != null,
            label: 'CommercePal',
            child: InkWell(
              onTap: onLogoTap,
              borderRadius: AppRadius.smAll,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.smAll,
                ),
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: AppRadius.xsAll,
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.storefront_rounded,
                      color: scheme.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          );

    final Widget search = Semantics(
      textField: onSearchTap == null,
      button: onSearchTap != null,
      label: placeholder,
      child: Material(
        color: searchFill,
        borderRadius: AppRadius.mdAll,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 42,
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: onSearchTap,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 12,
                          end: 6,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: searchIcon,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: onSearchTap != null
                            ? Text(
                                placeholder,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: searchIcon,
                                ),
                              )
                            : TextField(
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: placeholder,
                                  hintStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(color: searchIcon),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                style: theme.textTheme.bodyMedium,
                                onSubmitted: (String value) {
                                  if (value.trim().isEmpty) return;
                                  onSearchSubmitted(value.trim());
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showVisualSearch) ...<Widget>[
                Container(width: 1, height: 22, color: scheme.outlineVariant),
                IconButton(
                  tooltip: LocalizationService.t(
                    context,
                    'appBar.visualSearch',
                  ),
                  onPressed: () => _openVisualSearch(context),
                  icon: Icon(
                    Icons.photo_camera_outlined,
                    color: searchIcon,
                    size: 21,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(44, 42),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    final Widget cart = IconButton(
      tooltip: LocalizationService.t(context, 'nav.cart'),
      onPressed: onCartTap,
      icon: CountBadge(
        count: cartCount,
        child: Icon(
          Icons.shopping_cart_outlined,
          color: c.onHeader,
          size: 26,
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Material(
        color: c.header,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: barHeight,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: Spacing.sm,
                end: Spacing.xxs,
              ),
              child: Row(
                children: <Widget>[
                  leading,
                  const SizedBox(width: Spacing.xs),
                  Expanded(child: search),
                  if (additionalActions != null &&
                      additionalActions!.isNotEmpty)
                    ...additionalActions!,
                  cart,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
