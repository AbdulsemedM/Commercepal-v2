import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/services/localization_service.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final displayMessage = (message != null && message!.trim().isNotEmpty)
        ? message!
        : LocalizationService.t(context, 'auth.resetSuccess.message');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 56,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                LocalizationService.t(context, 'auth.resetSuccess.title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const Spacer(),
              AuthPrimaryButton(
                label: LocalizationService.t(
                  context,
                  'auth.resetSuccess.goToLogin',
                ),
                onPressed: () => context.go(AppRoutes.login),
                showArrow: false,
              ),
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
