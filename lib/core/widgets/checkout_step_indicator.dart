import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';

/// Read-only checkout funnel indicator (1-based [currentStep] of [totalSteps]).
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
    final int clamped = currentStep.clamp(1, totalSteps);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: <Widget>[
          for (int i = 1; i <= totalSteps; i++) ...<Widget>[
            if (i > 1) ...<Widget>[
              Container(
                width: 28,
                height: 2,
                margin: const EdgeInsets.only(bottom: 22),
                color: i <= clamped ? AppColors.primary : Colors.grey.shade300,
              ),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _StepCircle(
                  index: i,
                  currentStep: clamped,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 88,
                  child: Text(
                    labels[i - 1],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: i == clamped
                              ? AppColors.primary
                              : i < clamped
                                  ? AppColors.navy
                                  : Colors.grey.shade500,
                          fontWeight: i == clamped
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.currentStep,
  });

  final int index;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentStep;
    final bool isCompleted = index < currentStep;

    Widget inner;
    if (isCompleted) {
      inner = Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    } else if (isActive) {
      inner = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.pink.withOpacity(0.45),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$index',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    } else {
      inner = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$index',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    if (!isActive) return inner;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pink.withOpacity(0.15),
      ),
      child: inner,
    );
  }
}
