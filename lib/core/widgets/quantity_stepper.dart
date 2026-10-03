import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/localization_service.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// − qty + control for cart lines and product pages.
///
/// When [onRemove] is provided, the minus button becomes a trash icon at
/// [min] so the user can delete the line without a separate control.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.onRemove,
    this.busy = false,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final VoidCallback? onRemove;

  /// Disables both buttons while an update is in flight.
  final bool busy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final double h = compact ? 32 : 40;
    final bool atMin = value <= min;
    final bool showTrash = atMin && onRemove != null;

    Widget button({
      required IconData icon,
      required String tooltip,
      required VoidCallback? onTap,
    }) {
      return Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          radius: h * 0.6,
          child: SizedBox(
            width: h,
            height: h,
            child: Icon(
              icon,
              size: compact ? 16 : 18,
              color: onTap == null
                  ? scheme.onSurface.withValues(alpha: 0.3)
                  : scheme.onSurface,
            ),
          ),
        ),
      );
    }

    return Container(
      height: h,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          button(
            icon:
                showTrash ? Icons.delete_outline_rounded : Icons.remove_rounded,
            tooltip: showTrash
                ? context.tr('common.remove')
                : context.tr('common.decrease'),
            onTap: busy
                ? null
                : showTrash
                    ? onRemove
                    : atMin
                        ? null
                        : () => onChanged(value - 1),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: compact ? 24 : 32),
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              child: busy
                  ? SizedBox.square(
                      key: const ValueKey<String>('busy'),
                      dimension: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    )
                  : Text(
                      '$value',
                      key: ValueKey<int>(value),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFeatures: AppTypography.tabularFigures,
                      ),
                    ),
            ),
          ),
          button(
            icon: Icons.add_rounded,
            tooltip: context.tr('common.increase'),
            onTap: busy || value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
