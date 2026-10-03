import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme/tokens.dart';
import 'app_button.dart';

class AppDialogAction {
  const AppDialogAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
}

class AppDialog {
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? message,
    Widget? content,
    Widget? icon,
    List<AppDialogAction> actions = const [],
    bool isDismissible = true,
    bool isLoading = false,
    WillPopCallback? onWillPop,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: AppMotion.medium,
      pageBuilder: (
        BuildContext dialogContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return PopScope(
          canPop: isDismissible,
          onPopInvokedWithResult: (bool didPop, Object? result) async {
            if (didPop) return;
            if (onWillPop != null) {
              final bool allow = await onWillPop();
              if (allow && dialogContext.mounted) {
                Navigator.of(dialogContext).maybePop();
              }
            }
          },
          child: _AppDialogShell(
            title: title,
            message: message,
            content: content,
            icon: icon,
            actions: actions,
            isLoading: isLoading,
          ),
        );
      },
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        final CurvedAnimation curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _AppDialogShell extends StatelessWidget {
  const _AppDialogShell({
    this.title,
    this.message,
    this.content,
    this.icon,
    required this.actions,
    this.isLoading = false,
  });

  final String? title;
  final String? message;
  final Widget? content;
  final Widget? icon;
  final List<AppDialogAction> actions;
  final bool isLoading;

  bool get _hasDestructive =>
      actions.any((AppDialogAction a) => a.isDestructive);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Material(
            color: scheme.surface,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    _DialogIconHalo(icon: icon!, destructive: _hasDestructive),
                    const SizedBox(height: Spacing.md),
                  ],
                  if (title != null)
                    Semantics(
                      header: true,
                      child: Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  if (message != null) ...<Widget>[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (content != null) ...<Widget>[
                    const SizedBox(height: Spacing.md),
                    content!,
                  ],
                  if (isLoading) ...<Widget>[
                    const SizedBox(height: Spacing.lg),
                    SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                  if (actions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: Spacing.xl),
                    _DialogActions(actions: actions),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogIconHalo extends StatelessWidget {
  const _DialogIconHalo({
    required this.icon,
    required this.destructive,
  });

  final Widget icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: destructive ? scheme.errorContainer : scheme.primaryContainer,
      ),
      child: IconTheme(
        data: IconThemeData(
          color: destructive ? scheme.error : scheme.primary,
          size: 30,
        ),
        child: icon,
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.actions});

  final List<AppDialogAction> actions;

  List<AppDialogAction> get _resolved {
    final bool anyPrimary = actions.any((AppDialogAction a) => a.isPrimary);
    final bool anyDestructive =
        actions.any((AppDialogAction a) => a.isDestructive);
    if (anyPrimary || anyDestructive || actions.isEmpty) return actions;

    // Neutral confirm dialogs: promote the last action to primary.
    final int last = actions.length - 1;
    return <AppDialogAction>[
      for (int i = 0; i < actions.length; i++)
        if (i == last)
          AppDialogAction(
            label: actions[i].label,
            onPressed: actions[i].onPressed,
            isPrimary: true,
          )
        else
          actions[i],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<AppDialogAction> resolved = _resolved;

    if (resolved.length == 2) {
      return Row(
        children: <Widget>[
          Expanded(child: _ActionButton(action: resolved.first)),
          const SizedBox(width: Spacing.sm),
          Expanded(child: _ActionButton(action: resolved.last)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < resolved.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: Spacing.xs),
          _ActionButton(action: resolved[i]),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final AppDialogAction action;

  void _handleTap(BuildContext context) {
    action.onPressed?.call();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final AppButtonVariant variant = action.isDestructive
        ? AppButtonVariant.destructive
        : action.isPrimary
            ? AppButtonVariant.primary
            : AppButtonVariant.secondary;
    return AppButton(
      label: action.label,
      variant: variant,
      size: AppButtonSize.medium,
      onPressed: () => _handleTap(context),
    );
  }
}
