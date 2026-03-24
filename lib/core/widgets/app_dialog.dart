import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    final ThemeData theme = Theme.of(context);
    final TargetPlatform platform = theme.platform;

    final Widget dialogContent = _DialogBody(
      title: title,
      message: message,
      content: content,
      icon: icon,
      isLoading: isLoading,
    );

    final Widget dialog = _buildAdaptiveDialog(
      context: context,
      platform: platform,
      theme: theme,
      body: dialogContent,
      actions: actions,
    );

    final Widget wrapped = WillPopScope(
      onWillPop: onWillPop ?? () async => isDismissible,
      child: dialog,
    );

    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (ctx) => wrapped,
    );
  }

  static Widget _buildAdaptiveDialog({
    required BuildContext context,
    required TargetPlatform platform,
    required ThemeData theme,
    required Widget body,
    required List<AppDialogAction> actions,
  }) {
    final ColorScheme scheme = theme.colorScheme;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return CupertinoAlertDialog(
        title: _CupertinoTitle(child: body),
        content: const SizedBox.shrink(),
        actions: actions.map((a) {
          final TextStyle? base = CupertinoTheme.of(
            context,
          ).textTheme.actionTextStyle;
          TextStyle style = (base ?? const TextStyle()).copyWith(
            fontWeight: a.isPrimary ? FontWeight.w600 : FontWeight.w400,
            color: a.isDestructive
                ? CupertinoColors.systemRed
                : (a.isPrimary
                      ? Color(AppColors.primary.value)
                      : CupertinoColors.activeBlue),
          );
          return CupertinoDialogAction(
            onPressed: () {
              a.onPressed?.call();
              Navigator.of(context).maybePop();
            },
            isDestructiveAction: a.isDestructive,
            child: Text(a.label, style: style),
          );
        }).toList(),
      );
    }

    final List<Widget> materialActions = actions.map((a) {
      final ButtonStyle baseStyle = TextButton.styleFrom(
        foregroundColor: a.isDestructive
            ? scheme.error
            : (a.isPrimary ? scheme.onPrimary : scheme.primary),
        textStyle: TextStyle(
          fontWeight: a.isPrimary ? FontWeight.w600 : FontWeight.w400,
        ),
      );

      if (a.isPrimary) {
        return FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () {
            a.onPressed?.call();
            Navigator.of(context).maybePop();
          },
          child: Text(a.label),
        );
      }

      if (a.isDestructive) {
        return OutlinedButton(
          style: baseStyle.copyWith(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          onPressed: () {
            a.onPressed?.call();
            Navigator.of(context).maybePop();
          },
          child: Text(a.label),
        );
      }

      return TextButton(
        style: baseStyle.copyWith(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        onPressed: () {
          a.onPressed?.call();
          Navigator.of(context).maybePop();
        },
        child: Text(a.label),
      );
    }).toList();

    return AlertDialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 14,
      shadowColor: Colors.black.withOpacity(0.18),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: body,
      ),
      actions: materialActions,
    );
  }
}

class _DialogBody extends StatelessWidget {
  const _DialogBody({
    this.title,
    this.message,
    this.content,
    this.icon,
    this.isLoading = false,
  });

  final String? title;
  final String? message;
  final Widget? content;
  final Widget? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final List<Widget> columnChildren = <Widget>[
      if (icon != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  scheme.primary.withOpacity(0.18),
                  scheme.primary.withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: scheme.primary.withOpacity(0.22),
              ),
            ),
            child: IconTheme(
              data: IconThemeData(color: scheme.primary, size: 24),
              child: icon!,
            ),
          ),
        ),
      if (title != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      if (message != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
      if (content != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: content!,
        ),
      if (isLoading)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: scheme.primary,
              ),
            ),
          ),
        ),
    ];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: columnChildren,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoTitle extends StatelessWidget {
  const _CupertinoTitle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // CupertinoAlertDialog expects a title and an optional content; we place our composed body into the title area.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: child,
    );
  }
}
