import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/localization_service.dart';

/// One-time tips after install (client-only).
Future<void> maybeShowDashboardCoachOverlay(BuildContext context) async {
  final storage = Storage();
  if (await storage.isDashboardCoachmarksDone()) return;
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(LocalizationService.t(ctx, 'coach.title')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(LocalizationService.t(ctx, 'coach.body')),
              const SizedBox(height: Spacing.md),
              Text('• ${LocalizationService.t(ctx, 'coach.tipSearch')}'),
              Text('• ${LocalizationService.t(ctx, 'coach.tipCart')}'),
              Text('• ${LocalizationService.t(ctx, 'coach.tipWishlist')}'),
              Text('• ${LocalizationService.t(ctx, 'coach.tipLanguage')}'),
            ],
          ),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () async {
              await storage.setDashboardCoachmarksDone();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(LocalizationService.t(ctx, 'coach.gotIt')),
          ),
        ],
      );
    },
  );
}
