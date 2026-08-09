import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/theme/colors.dart';

/// Camera and URL shortcuts for visual product search.
class VisualSearchEntryActions extends StatelessWidget {
  const VisualSearchEntryActions({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final Color color = iconColor ?? AppColors.navy;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          tooltip: 'Visual search',
          icon: Icon(Icons.camera_alt_outlined, color: color, size: 22),
          onPressed: () => context.push(AppRoutes.visualSearch),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        IconButton(
          tooltip: 'Search by URL',
          icon: Icon(Icons.link, color: color, size: 22),
          onPressed: () => context.push(AppRoutes.visualSearch),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}
