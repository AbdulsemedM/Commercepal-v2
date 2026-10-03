import 'package:flutter/material.dart';

import 'package:commercepal/core/widgets/section_header.dart';

/// Home section header. Thin wrapper over [SectionHeader] (callers already
/// apply horizontal padding).
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: title,
      actionLabel: actionLabel,
      onAction: onAction,
      padding: EdgeInsets.zero,
    );
  }
}
