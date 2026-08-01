import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.t(context, 'auth.otp.sessionExpired'),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
    return BlocProvider(
      create: (context) => ResetPasswordBloc(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        if (_emailOrPhone.isNotEmpty) ...[
                          const SizedBox(height: Spacing.md),
                          Text(
                            LocalizationService.t(
                              context,
                              'auth.reset.codeSentTo',
                            ).replaceAll('{target}', _emailOrPhone),
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
                            if (value.length < 8) {
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
                          onPressed: _canSubmit && !isLoading
                              ? () => _submit(context)
                              : null,
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
