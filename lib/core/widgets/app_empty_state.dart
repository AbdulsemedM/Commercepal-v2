import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import 'app_button.dart';

/// Empty, error or "nothing found" state with optional actions.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.isError = false,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Tints the illustration with the error colour.
  final bool isError;

  /// Smaller illustration for inline use inside cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final double halo = compact ? 72 : 104;
    final Color tint = isError ? scheme.error : scheme.primary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: halo,
                height: halo,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isError
                      ? scheme.errorContainer
                      : scheme.surfaceContainerHigh,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: halo * 0.44,
                  color: tint.withValues(alpha: isError ? 1 : 0.85),
                ),
              ),
              SizedBox(height: compact ? Spacing.md : Spacing.lg),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: (compact
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.titleLarge)
                      ?.copyWith(color: scheme.onSurface),
                  textAlign: TextAlign.center,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                const SizedBox(height: Spacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (primaryLabel != null && onPrimary != null) ...<Widget>[
                SizedBox(height: compact ? Spacing.md : Spacing.xl),
                AppButton.primary(
                  label: primaryLabel!,
                  onPressed: onPrimary,
                  size: compact ? AppButtonSize.medium : AppButtonSize.large,
                  fullWidth: false,
                ),
              ],
              if (secondaryLabel != null && onSecondary != null) ...<Widget>[
                const SizedBox(height: Spacing.xs),
                AppButton.text(
                  label: secondaryLabel!,
                  onPressed: onSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
