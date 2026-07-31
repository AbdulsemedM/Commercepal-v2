import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/login/presentation/widgets/login_widgets.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../bloc/reset_password_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.target, this.verificationToken});

  final String? target;
  final String? verificationToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _verificationTokenController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _hasPrefillTarget =>
      widget.target != null && widget.target!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.target != null) {
      _targetController.text = widget.target!;
    }
    if (widget.verificationToken != null) {
      _verificationTokenController.text = widget.verificationToken!;
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    _verificationTokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;
    context.read<ResetPasswordBloc>().add(
      ResetPasswordSubmitted(
        target: _targetController.text.trim(),
        verificationToken: _verificationTokenController.text.trim(),
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
        channel: PlatformUtils.getChannel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordBloc(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocListener<ResetPasswordBloc, ResetPasswordState>(
            listener: (context, state) {
              if (state is ResetPasswordSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(seconds: 2), () {
                  if (!context.mounted) return;
                  context.go(AppRoutes.login);
                });
              } else if (state is ResetPasswordFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
              builder: (context, state) {
                final bool isLoading = state is ResetPasswordLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
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
                        Text(
                          LocalizationService.t(
                            context,
                            'auth.reset.title',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                              ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          LocalizationService.t(
                            context,
                            'auth.reset.subtitle',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        if (_hasPrefillTarget) ...[
                          const SizedBox(height: Spacing.md),
                          Text(
                            LocalizationService.t(
                              context,
                              'auth.reset.codeSentTo',
                            ).replaceAll('{target}', _targetController.text),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                        const SizedBox(height: Spacing.lg),
                        if (!_hasPrefillTarget) ...[
                          AuthTextField(
                            label: LocalizationService.t(
                              context,
                              'auth.reset.target',
                            ),
                            hintText: LocalizationService.t(
                              context,
                              'auth.reset.targetHint',
                            ),
                            controller: _targetController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocalizationService.t(
                                  context,
                                  'auth.reset.targetRequired',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: Spacing.md),
                        ],
                        AuthTextField(
                          label: LocalizationService.t(
                            context,
                            'auth.reset.verificationCode',
                          ),
                          hintText: LocalizationService.t(
                            context,
                            'auth.reset.verificationCodeHint',
                          ),
                          controller: _verificationTokenController,
                          keyboardType: TextInputType.number,
                          enabled: widget.verificationToken == null,
                          maxLength: 8,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocalizationService.t(
                                context,
                                'auth.reset.verificationCodeRequired',
                              );
                            }
                            if (value.length < 4) {
                              return LocalizationService.t(
                                context,
                                'auth.reset.verificationCodeInvalid',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                        PasswordInputField(
                          controller: _newPasswordController,
                          label: LocalizationService.t(
                            context,
                            'auth.reset.newPassword',
                          ),
                          hintText: LocalizationService.t(
                            context,
                            'auth.reset.newPasswordHint',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocalizationService.t(
                                context,
                                'auth.reset.newPasswordRequired',
                              );
                            }
                            if (value.length < 6) {
                              return LocalizationService.t(
                                context,
                                'auth.reset.passwordTooShort',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                        PasswordInputField(
                          controller: _confirmPasswordController,
                          label: LocalizationService.t(
                            context,
                            'auth.reset.confirmPassword',
                          ),
                          hintText: LocalizationService.t(
                            context,
                            'auth.reset.confirmPasswordHint',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocalizationService.t(
                                context,
                                'auth.reset.confirmPasswordRequired',
                              );
                            }
                            if (value != _newPasswordController.text) {
                              return LocalizationService.t(
                                context,
                                'auth.reset.passwordsDoNotMatch',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Spacing.lg),
                        AuthPrimaryButton(
                          label: LocalizationService.t(
                            context,
                            'auth.reset.submit',
                          ),
                          isLoading: isLoading,
                          onPressed: () => _submit(context),
                        ),
                        const SizedBox(height: Spacing.md),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Text(
                              LocalizationService.t(
                                context,
                                'auth.reset.backToLogin',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.pink,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.xl),
                      ],
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
