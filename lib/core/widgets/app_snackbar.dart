import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppSnackbars {
  AppSnackbars._();

  static void _show(
    BuildContext context,
    String message, {
    Color? bg,
    Color? fg,
  }) {
    final ThemeData theme = Theme.of(context);
    final SnackBar snack = SnackBar(
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: fg ?? theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: bg ?? theme.colorScheme.surface,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  static void success(BuildContext context, String message) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      bg: AppColors.success.withOpacity(0.1),
      fg: cs.onSurface,
    );
  }

  static void error(BuildContext context, String message) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      bg: AppColors.error.withOpacity(0.1),
      fg: cs.onSurface,
    );
  }

  static void info(BuildContext context, String message) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      bg: AppColors.info.withOpacity(0.1),
      fg: cs.onSurface,
    );
  }
}
