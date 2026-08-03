import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/services/localization_service.dart';

class SupportQuickActions extends StatelessWidget {
  const SupportQuickActions({
    super.key,
    required this.onSelected,
    this.enabled = true,
  });

  final ValueChanged<String> onSelected;
  final bool enabled;

  static const List<(String key, String fallback)> _actions =
      <(String, String)>[
    ('supportChat.quickAction.whyCommercePal', 'Why CommercePal?'),
    ('supportChat.quickAction.freeShipping', 'Free shipping?'),
    ('supportChat.quickAction.trackOrder', 'Track my order'),
    ('supportChat.quickAction.shareProduct', 'Share a product link'),
    ('supportChat.quickAction.talkToAgent', 'Talk to an agent'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: _actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
        itemBuilder: (BuildContext context, int index) {
          final (String key, String fallback) = _actions[index];
          final String label = LocalizationService.t(context, key);
          final String text = label == key ? fallback : label;
          return ActionChip(
            label: Text(text),
            onPressed: enabled ? () => onSelected(text) : null,
            backgroundColor: Colors.white,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.navy,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}
