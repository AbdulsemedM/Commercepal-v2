import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/theme/colors.dart';

/// Camera shortcut for visual product search (e.g. inside custom search fields).
class VisualSearchEntryActions extends StatelessWidget {
  const VisualSearchEntryActions({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final Color color = iconColor ?? AppColors.navy;
    return IconButton(
      tooltip: 'Visual search',
      icon: Icon(Icons.camera_alt_outlined, color: color, size: 22),
      onPressed: () => context.push(AppRoutes.visualSearch),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
