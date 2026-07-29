import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/core/utils/phone_utils.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/login/presentation/widgets/login_widgets.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../bloc/forgot_password_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LoginMethod _method = LoginMethod.email;
  String _completePhoneNumber = '';
  String? _pendingTarget;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _resolveTarget() {
    if (_method == LoginMethod.email) {
      return _emailController.text.trim();
    }
    final String raw = _completePhoneNumber.isNotEmpty
        ? _completePhoneNumber
        : _phoneController.text.trim();
    // Prefer E.164 with '+' to match forgot-password API examples.
    if (raw.startsWith('+')) return raw;
    final String normalized = PhoneUtils.normalizeLoginIdentifier(raw);
    return normalized.isEmpty ? raw : '+$normalized';
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;

    final String target = _resolveTarget();
    if (_method == LoginMethod.phone) {
      final String normalized = PhoneUtils.normalizeLoginIdentifier(target);
      if (!PhoneUtils.isValidLoginIdentifier(normalized)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.t(context, 'auth.login.phoneInvalid'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    _pendingTarget = target;
    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordSubmitted(
        emailOrPhone: target,
        channel: PlatformUtils.getChannel(),
      ),
    );
  }

  void _goToReset(String target) {
    context.push(
      Uri(
        path: AppRoutes.resetPassword,
        queryParameters: <String, String>{'target': target},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                final String target = _pendingTarget ?? _resolveTarget();
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (!context.mounted) return;
                  _goToReset(target);
                });
              } else if (state is ForgotPasswordFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
              builder: (context, state) {
                final bool isLoading = state is ForgotPasswordLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: Spacing.md),
                        AuthBackButton(onPressed: () => context.pop()),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          LocalizationService.t(
                            context,
                            'auth.forgot.title',
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
                            'auth.forgot.subtitle',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: Spacing.lg),
                        LoginMethodTabs(
                          selected: _method,
                          onChanged: (LoginMethod method) {
                            setState(() {
                              _method = method;
                            });
                          },
                        ),
                        const SizedBox(height: Spacing.lg),
                        if (_method == LoginMethod.email)
                          EmailInputField(controller: _emailController)
                        else
                          PhoneLoginInputField(
                            controller: _phoneController,
                            onCompleteNumberChanged: (String complete) {
                              setState(() {
                                _completePhoneNumber = complete;
                              });
                            },
                          ),
                        const SizedBox(height: Spacing.lg),
                        AuthPrimaryButton(
                          label: LocalizationService.t(
                            context,
                            'auth.forgot.sendCode',
                          ),
                          isLoading: isLoading,
                          onPressed: () => _submit(context),
                        ),
                        const SizedBox(height: Spacing.md),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              LocalizationService.t(
                                context,
                                'auth.forgot.backToLogin',
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
