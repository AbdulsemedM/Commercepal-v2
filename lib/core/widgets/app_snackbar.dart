import 'package:flutter/material.dart';

import '../theme/commerce_colors.dart';

enum _SnackTone { success, error, info, neutral }

/// Consistent floating snackbars with a tone icon.
///
/// ```dart
/// AppSnackbars.success(context, 'Added to cart',
///     actionLabel: 'View cart', onAction: () => ...);
/// ```
class AppSnackbars {
  AppSnackbars._();

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      _show(context, message, _SnackTone.success, actionLabel, onAction);

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      _show(context, message, _SnackTone.error, actionLabel, onAction);

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      _show(context, message, _SnackTone.info, actionLabel, onAction);

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      _show(context, message, _SnackTone.neutral, actionLabel, onAction);

  static void _show(
    BuildContext context,
    String message,
    _SnackTone tone,
    String? actionLabel,
    VoidCallback? onAction,
  ) {
    final ScaffoldMessengerState? messenger =
        ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final CommerceColors c = context.commerce;

    // Accent colours chosen to read on the inverse (dark-in-light) surface.
    final (IconData? icon, Color accent) = switch (tone) {
      _SnackTone.success => (Icons.check_circle_rounded, c.success),
      _SnackTone.error => (Icons.error_rounded, scheme.error),
      _SnackTone.info => (Icons.info_rounded, c.info),
      _SnackTone.neutral => (null, scheme.onInverseSurface),
    };
    final bool lightTheme = scheme.brightness == Brightness.light;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(
            seconds: tone == _SnackTone.error || actionLabel != null ? 5 : 3,
          ),
          content: Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(
                  icon,
                  size: 20,
                  // Lighten accents on the dark inverse surface in light mode.
                  color: lightTheme
                      ? Color.lerp(accent, Colors.white, 0.35)
                      : accent,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: Text(message)),
            ],
          ),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }
}
