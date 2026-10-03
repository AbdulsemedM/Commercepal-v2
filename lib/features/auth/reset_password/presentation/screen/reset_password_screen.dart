import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/login/presentation/widgets/login_widgets.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../bloc/reset_password_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.target,
    this.verificationToken,
  });

  final String? target;
  final String? verificationToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _canSubmit = false;

  String get _emailOrPhone => widget.target?.trim() ?? '';
  String get _verificationCode => widget.verificationToken?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_updateCanSubmit);
    _confirmPasswordController.addListener(_updateCanSubmit);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_updateCanSubmit);
    _confirmPasswordController.removeListener(_updateCanSubmit);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateCanSubmit() {
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    final canSubmit = newPassword.length >= 8 &&
        confirm == newPassword &&
        _emailOrPhone.isNotEmpty &&
        RegExp(r'^\d{6}$').hasMatch(_verificationCode);
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;
    if (_emailOrPhone.isEmpty ||
        !RegExp(r'^\d{6}$').hasMatch(_verificationCode)) {
      AppSnackbars.error(context, context.tr('auth.otp.sessionExpired'));
      context.go(AppRoutes.forgotPassword);
      return;
    }

    context.read<ResetPasswordBloc>().add(
          ResetPasswordSubmitted(
            emailOrPhone: _emailOrPhone,
            verificationCode: _verificationCode,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return BlocProvider(
      create: (context) => ResetPasswordBloc(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<ResetPasswordBloc, ResetPasswordState>(
            listener: (context, state) {
              if (state is ResetPasswordSuccess) {
                context.go(
                  Uri(
                    path: AppRoutes.passwordResetSuccess,
                    queryParameters: <String, String>{
                      'message': state.message,
                    },
                  ).toString(),
                );
              } else if (state is ResetPasswordFailure) {
                AppSnackbars.error(context, state.message);
              }
            },
            child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
              builder: (context, state) {
                final bool isLoading = state is ResetPasswordLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: Spacing.md),
                              AuthBackButton(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go(AppRoutes.login);
                                  }
                                },
                              ),
                              const SizedBox(height: Spacing.sm),
                              Semantics(
                                header: true,
                                child: Text(
                                  context.tr('auth.reset.title'),
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                context.tr('auth.reset.subtitle'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              if (_emailOrPhone.isNotEmpty) ...[
                                const SizedBox(height: Spacing.md),
                                _TargetChip(
                                  label: context.tr(
                                    'auth.reset.codeSentTo',
                                    <String, Object?>{'target': _emailOrPhone},
                                  ),
                                ),
                              ],
                              const SizedBox(height: Spacing.xl),
                              PasswordInputField(
                                controller: _newPasswordController,
                                isNewPassword: true,
                                textInputAction: TextInputAction.next,
                                label: context.tr('auth.reset.newPassword'),
                                hintText: context.tr('auth.reset.newPasswordHint'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context
                                        .tr('auth.reset.newPasswordRequired');
                                  }
                                  if (value.length < 8) {
                                    return context
                                        .tr('auth.reset.passwordTooShort');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Spacing.md),
                              PasswordInputField(
                                controller: _confirmPasswordController,
                                isNewPassword: true,
                                label: context.tr('auth.reset.confirmPassword'),
                                hintText:
                                    context.tr('auth.reset.confirmPasswordHint'),
                                onSubmitted: (_) {
                                  if (_canSubmit && !isLoading) {
                                    _submit(context);
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context.tr(
                                      'auth.reset.confirmPasswordRequired',
                                    );
                                  }
                                  if (value != _newPasswordController.text) {
                                    return context
                                        .tr('auth.reset.passwordsDoNotMatch');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Spacing.xl),
                              AuthPrimaryButton(
                                label: context.tr('auth.reset.submit'),
                                isLoading: isLoading,
                                onPressed: _canSubmit && !isLoading
                                    ? () => _submit(context)
                                    : null,
                              ),
                              const SizedBox(height: Spacing.md),
                              Center(
                                child: AppButton.text(
                                  label: context.tr('auth.reset.backToLogin'),
                                  onPressed: () => context.go(AppRoutes.login),
                                ),
                              ),
                              const SizedBox(height: Spacing.xl),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiet pill naming the account whose password is being reset.
class _TargetChip extends StatelessWidget {
  const _TargetChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.lock_reset_rounded,
              size: AppSizes.iconMd,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
