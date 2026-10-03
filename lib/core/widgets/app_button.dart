import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/commerce_colors.dart';
import '../theme/tokens.dart';

enum AppButtonVariant {
  /// Maroon fill — the single most important action on a screen.
  primary,

  /// Ink outline — the alternative action (e.g. "Buy now" next to "Add").
  secondary,

  /// Soft fill — low-emphasis actions in cards and sheets.
  tonal,

  /// Amber-orange fill — deal / limited-time actions only.
  deal,

  /// Red outline — irreversible actions (delete, cancel order).
  destructive,

  /// Text only.
  text,
}

enum AppButtonSize { small, medium, large }

/// The app's button. Wraps Material buttons so every CTA shares the same
/// heights, shapes, loading behaviour and haptics.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = true,
    this.haptic = true,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = true,
    this.haptic = true,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = true,
    this.haptic = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = true,
    this.haptic = true,
  }) : variant = AppButtonVariant.tonal;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.haptic = false,
  }) : variant = AppButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Shows a spinner and blocks taps while keeping the button's width.
  final bool loading;
  final bool fullWidth;
  final bool haptic;

  double get _height => switch (size) {
        AppButtonSize.small => AppSizes.buttonSm,
        AppButtonSize.medium => AppSizes.buttonMd,
        AppButtonSize.large => AppSizes.buttonLg,
      };

  double get _fontSize => switch (size) {
        AppButtonSize.small => 13,
        AppButtonSize.medium => 14,
        AppButtonSize.large => 15,
      };

  double get _hPadding => switch (size) {
        AppButtonSize.small => 14,
        AppButtonSize.medium => 18,
        AppButtonSize.large => 24,
      };

  void _handlePressed() {
    if (haptic) HapticFeedback.lightImpact();
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    final bool enabled = onPressed != null && !loading;

    final (Color bg, Color fg, BorderSide? side) = switch (variant) {
      AppButtonVariant.primary => (commerce.cta, commerce.onCta, null),
      AppButtonVariant.secondary => (
          Colors.transparent,
          scheme.onSurface,
          BorderSide(color: scheme.onSurface.withValues(alpha: 0.7)),
        ),
      AppButtonVariant.tonal => (
          scheme.surfaceContainerHigh,
          scheme.onSurface,
          null,
        ),
      AppButtonVariant.deal => (commerce.deal, commerce.onDeal, null),
      AppButtonVariant.destructive => (
          Colors.transparent,
          scheme.error,
          BorderSide(color: scheme.error.withValues(alpha: 0.6)),
        ),
      AppButtonVariant.text => (Colors.transparent, scheme.primary, null),
    };

    final ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(fullWidth ? double.infinity : 64, _height),
      ),
      fixedSize: WidgetStatePropertyAll<Size?>(
        fullWidth ? Size.fromHeight(_height) : null,
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: _hPadding),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        variant == AppButtonVariant.text
            ? const RoundedRectangleBorder(borderRadius: AppRadius.smAll)
            : const StadiumBorder(),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (s.contains(WidgetState.disabled) && !loading) {
          return bg == Colors.transparent
              ? Colors.transparent
              : scheme.onSurface.withValues(alpha: 0.1);
        }
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (s.contains(WidgetState.disabled) && !loading) {
          return scheme.onSurface.withValues(alpha: 0.38);
        }
        return fg;
      }),
      overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (s.contains(WidgetState.pressed)) return fg.withValues(alpha: 0.12);
        if (s.contains(WidgetState.hovered) ||
            s.contains(WidgetState.focused)) {
          return fg.withValues(alpha: 0.08);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (side == null) return null;
        if (s.contains(WidgetState.disabled) && !loading) {
          return BorderSide(color: scheme.onSurface.withValues(alpha: 0.12));
        }
        return side;
      }),
      textStyle: WidgetStatePropertyAll<TextStyle?>(
        theme.textTheme.labelLarge?.copyWith(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      animationDuration: AppMotion.fast,
    );

    final double iconSize = size == AppButtonSize.small ? 16 : 18;
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: iconSize),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (trailingIcon != null) ...<Widget>[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: iconSize),
        ],
      ],
    );

    final Widget child = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // Keep the label laid out (but invisible) so width doesn't jump.
        Opacity(opacity: loading ? 0 : 1, child: content),
        if (loading)
          SizedBox.square(
            dimension: iconSize + 2,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? '$label…' : null,
      excludeSemantics: loading,
      child: TextButton(
        onPressed: enabled ? _handlePressed : (loading ? () {} : null),
        style: style,
        child: child,
      ),
    );
  }
}
