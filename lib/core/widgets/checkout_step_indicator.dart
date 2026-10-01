import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme/tokens.dart';

/// Read-only checkout progress (1-based [currentStep] of [totalSteps]).
class CheckoutStepIndicator extends StatelessWidget {
  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
  })  : assert(totalSteps > 0),
        assert(labels.length == totalSteps);

  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int current = currentStep.clamp(1, totalSteps);

    return Semantics(
      label: '${labels[current - 1]} · $current/$totalSteps',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.gutter,
          vertical: Spacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 1; i <= totalSteps; i++)
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: i == 1
                              ? const SizedBox()
                              : _Line(active: i <= current),
                        ),
                        _Dot(index: i, current: current),
                        Expanded(
                          child: i == totalSteps
                              ? const SizedBox()
                              : _Line(active: i < current),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i - 1],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: i == current
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight:
                            i == current ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.medium,
      height: 2,
      color: active ? scheme.primary : scheme.outlineVariant,
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.current});

  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool done = index < current;
    final bool active = index == current;

    return AnimatedContainer(
      duration: AppMotion.medium,
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || active ? scheme.primary : scheme.surface,
        border: Border.all(
          color: done || active ? scheme.primary : scheme.outline,
          width: 1.5,
        ),
      ),
      child: done
          ? Icon(Icons.check_rounded, size: 16, color: scheme.onPrimary)
          : Text(
              '$index',
              style: theme.textTheme.labelMedium?.copyWith(
                color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
