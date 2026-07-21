import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';

/// Shared cream rounded back-button + bold title used on checkout screens.
class CheckoutScreenHeader extends StatelessWidget {
  const CheckoutScreenHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Material(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF0E6D8)),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.navy,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
