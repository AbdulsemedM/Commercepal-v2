import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/design_system.dart';
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
        AppSnackbars.error(context, context.tr('auth.login.phoneInvalid'));
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

  void _goToVerifyOtp(String target) {
    context.push(
      Uri(
        path: AppRoutes.verifyOtp,
        queryParameters: <String, String>{'target': target},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                AppSnackbars.success(context, state.message);
                final String target = _pendingTarget ?? _resolveTarget();
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (!context.mounted) return;
                  _goToVerifyOtp(target);
                });
              } else if (state is ForgotPasswordFailure) {
                AppSnackbars.error(context, state.message);
              }
            },
            child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
              builder: (context, state) {
                final bool isLoading = state is ForgotPasswordLoading;
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
                              AuthBackButton(onPressed: () => context.pop()),
                              const SizedBox(height: Spacing.sm),
                              Semantics(
                                header: true,
                                child: Text(
                                  context.tr('auth.forgot.title'),
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                context.tr('auth.forgot.subtitle'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
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
                              const SizedBox(height: Spacing.xl),
                              AuthPrimaryButton(
                                label: context.tr('auth.forgot.sendCode'),
                                isLoading: isLoading,
                                onPressed: () => _submit(context),
                              ),
                              const SizedBox(height: Spacing.md),
                              Center(
                                child: AppButton.text(
                                  label: context.tr('auth.forgot.backToLogin'),
                                  onPressed: () => context.pop(),
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
