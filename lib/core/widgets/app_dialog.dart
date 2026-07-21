import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme/app_decorations.dart';
import '../theme/colors.dart';

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
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
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
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? Theme.of(context).colorScheme.surface
        : Colors.white;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: isDark ? 0.95 : 0.98),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _hasDestructive
                          ? AppColors.error.withValues(alpha: 0.18)
                          : AppColors.pink.withValues(alpha: 0.12),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: (_hasDestructive
                                ? AppColors.error
                                : AppColors.primary)
                            .withValues(alpha: 0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      // Soft decorative gradient wash behind the icon.
                      Positioned(
                        top: -40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 160,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: <Color>[
                                  (_hasDestructive
                                          ? AppColors.error
                                          : AppColors.pink)
                                      .withValues(alpha: 0.18),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (icon != null) ...[
                              _DialogIconHalo(
                                icon: icon!,
                                destructive: _hasDestructive,
                              ),
                              const SizedBox(height: Spacing.md),
                            ],
                            if (title != null)
                              Text(
                                title!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? null
                                          : AppColors.navy,
                                      fontSize: 20,
                                      height: 1.25,
                                    ),
                              ),
                            if (message != null) ...[
                              const SizedBox(height: Spacing.sm),
                              Text(
                                message!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      height: 1.45,
                                    ),
                              ),
                            ],
                            if (content != null) ...[
                              const SizedBox(height: Spacing.md),
                              content!,
                            ],
                            if (isLoading) ...[
                              const SizedBox(height: Spacing.lg),
                              const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            if (actions.isNotEmpty) ...[
                              const SizedBox(height: Spacing.lg),
                              _DialogActions(actions: actions),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
    final Color accent = destructive ? AppColors.error : AppColors.pink;
    final LinearGradient gradient = destructive
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF87171),
              AppColors.error,
            ],
          )
        : AppDecorations.primaryCtaGradient;

    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
      ),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: const IconThemeData(color: Colors.white, size: 28),
          child: icon,
        ),
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

    // Neutral confirm dialogs: give the last action the gradient pill.
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

    if (resolved.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: _ActionButton(
          action: resolved.first,
          expanded: true,
        ),
      );
    }

    if (resolved.length == 2) {
      return Row(
        children: <Widget>[
          Expanded(
            child: _ActionButton(
              action: resolved.first,
              expanded: true,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: _ActionButton(
              action: resolved.last,
              expanded: true,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < resolved.length; i++) ...[
          if (i > 0) const SizedBox(height: Spacing.sm),
          _ActionButton(action: resolved[i], expanded: true),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    this.expanded = false,
  });

  final AppDialogAction action;
  final bool expanded;

  void _handleTap(BuildContext context) {
    action.onPressed?.call();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (action.isDestructive) {
      return _buildOutlined(
        context,
        foreground: AppColors.error,
        border: AppColors.error.withValues(alpha: 0.45),
        fill: AppColors.error.withValues(alpha: 0.06),
      );
    }

    if (action.isPrimary) {
      return _buildGradient(context);
    }

    return _buildOutlined(
      context,
      foreground: AppColors.navy,
      border: const Color(0xFFE8DFD2),
      fill: AppDecorations.softCream,
    );
  }

  Widget _buildGradient(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppDecorations.primaryCtaGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.pink.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlined(
    BuildContext context, {
    required Color foreground,
    required Color border,
    required Color fill,
  }) {
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: border),
          ),
          child: Text(
            action.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
