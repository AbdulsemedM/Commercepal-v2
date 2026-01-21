import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import '../../bloc/login_bloc.dart';
import '../widgets/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.hideBackButton = false});

  final bool hideBackButton;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                // Navigate to dashboard on successful login
                context.go(AppRoutes.dashboard);
              } else if (state is LoginFailure) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                final isLoading = state is LoginLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (!widget.hideBackButton) ...[
                          const SizedBox(height: Spacing.md),
                          // Back button
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(Spacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ] else
                          const SizedBox(height: Spacing.lg),
                        const SizedBox(height: Spacing.sm),
                        // Title
                        Text(
                          LocalizationService.t(context, 'auth.login.title'),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        // Subtitle
                        Text(
                          LocalizationService.t(context, 'auth.login.subtitle'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: Spacing.lg),
                        // Email field
                        EmailInputField(controller: _emailController),
                        const SizedBox(height: Spacing.md),
                        // Password field
                        PasswordInputField(controller: _passwordController),
                        const SizedBox(height: Spacing.sm),
                        // Forgot password link
                        ForgotPasswordLink(
                          onTap: () {
                            context.push(AppRoutes.forgotPassword);
                          },
                        ),
                        const SizedBox(height: Spacing.lg),
                        // Login button with arrow icon
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      context.read<LoginBloc>().add(
                                        LoginSubmitted(
                                          loginIdentifier: _emailController.text
                                              .trim(),
                                          password: _passwordController.text,
                                          channel: PlatformUtils.getChannel(),
                                        ),
                                      );
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.md,
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        LocalizationService.t(
                                          context,
                                          'auth.login.loginButton',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(width: Spacing.xs),
                                      const Icon(
                                        Icons.arrow_forward,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        // Or separator
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                              ),
                              child: Text(
                                LocalizationService.t(context, 'auth.login.or'),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xl),
                        // Social login buttons
                        SocialLoginButton(
                          type: SocialLoginType.google,
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<LoginBloc>().add(
                                    GoogleSignInRequested(
                                      channel: PlatformUtils.getChannel(),
                                    ),
                                  );
                                },
                        ),
                        const SizedBox(height: Spacing.md),
                        SocialLoginButton(
                          type: SocialLoginType.facebook,
                          onPressed: () {
                            // TODO: Handle Facebook login
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                        SocialLoginButton(
                          type: SocialLoginType.apple,
                          onPressed: () {
                            // TODO: Handle Apple login
                          },
                        ),
                        const SizedBox(height: Spacing.xxl),
                        // Sign up link
                        SignUpLink(
                          onTap: () {
                            context.push(AppRoutes.signup);
                          },
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
