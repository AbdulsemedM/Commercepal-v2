import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/services/localization_service.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    final displayMessage = (message != null && message!.trim().isNotEmpty)
        ? message!
        : context.tr('auth.resetSuccess.message');

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  ExcludeSemantics(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: commerce.successContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: commerce.success,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                  Semantics(
                    header: true,
                    liveRegion: true,
                    child: Text(
                      context.tr('auth.resetSuccess.title'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    displayMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  AuthPrimaryButton(
                    label: context.tr('auth.resetSuccess.goToLogin'),
                    onPressed: () => context.go(AppRoutes.login),
                    showArrow: false,
                  ),
                  const SizedBox(height: Spacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
