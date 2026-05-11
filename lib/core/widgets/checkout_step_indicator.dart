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
                width: 20,
                height: 2,
                margin: const EdgeInsets.only(bottom: 20),
                color: i <= clamped ? AppColors.primary : Colors.grey.shade300,
              ),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      i <= clamped ? AppColors.primary : Colors.grey.shade300,
                  child: Text(
                    '$i',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: i <= clamped ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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
                              : Colors.grey.shade600,
                          fontWeight:
                              i == clamped ? FontWeight.w600 : FontWeight.w400,
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
