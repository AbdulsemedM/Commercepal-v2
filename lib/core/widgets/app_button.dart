import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, tonal, text }

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = true,
  }) : variant = AppButtonVariant.primary;
  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = true,
  }) : variant = AppButtonVariant.secondary;
  const AppButton.tonal({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = true,
  }) : variant = AppButtonVariant.tonal;
  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
  }) : variant = AppButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final Widget child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          )
        : Text(label);

    final ButtonStyle? style = switch (variant) {
      AppButtonVariant.primary => FilledButton.styleFrom(),
      AppButtonVariant.secondary => OutlinedButton.styleFrom(),
      AppButtonVariant.tonal => null,
      AppButtonVariant.text => TextButton.styleFrom(),
    };

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: loading ? null : onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.tonal => FilledButton.tonal(
        onPressed: loading ? null : onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: loading ? null : onPressed,
        style: style,
        child: child,
      ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
