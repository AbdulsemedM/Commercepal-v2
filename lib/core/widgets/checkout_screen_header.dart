import 'package:flutter/material.dart';

import '../constants/spacing.dart';

/// Back button + title used across the checkout flow.
class CheckoutScreenHeader extends StatelessWidget {
  const CheckoutScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  /// Hide on terminal screens (order placed) where back makes no sense.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        showBack ? Spacing.xxs : Spacing.gutter,
        Spacing.xxs,
        Spacing.xs,
        Spacing.xxs,
      ),
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: <Widget>[
            if (showBack)
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: const BackButtonIcon(),
              ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
