import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/localization_service.dart';
// import 'package:commercepal/services/biometric_service.dart';
// import 'package:commercepal/services/auth_service.dart';
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
  bool _rememberMe = false;
  final Storage _storage = Storage();
  // final BiometricService _biometricService = BiometricService();
  // bool _showBiometricLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillRememberedEmail();
      // _checkBiometricLoginAvailable();
    });
  }

  // Future<void> _checkBiometricLoginAvailable() async {
  //   final biometricEnabled = await _storage.getBiometricEnabled();
  //   final hasTokens = await _storage.hasTokens();
  //   if (mounted && biometricEnabled && hasTokens) {
  //     setState(() => _showBiometricLogin = true);
  //   }
  // }

  Future<void> _prefillRememberedEmail() async {
    final email = await _storage.getRememberedEmail();
    if (email != null && email.isNotEmpty && mounted) {
      setState(() {
        _emailController.text = email;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _maybeShowEnableBiometricDialog(BuildContext context) async {
  //   final hasBiometrics = await _biometricService.hasEnrolledBiometrics;
  //   final alreadyEnabled = await _storage.getBiometricEnabled();
  //   if (!hasBiometrics || alreadyEnabled || !mounted) return;

  //   final enable = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       title: Text(
  //         LocalizationService.t(context, 'auth.biometric.enableTitle'),
  //       ),
  //       content: Text(
  //         LocalizationService.t(context, 'auth.biometric.enableMessage'),
  //       ),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: Text(
  //             LocalizationService.t(context, 'auth.biometric.notNow'),
  //           ),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.of(context).pop(true),
  //           child: Text(
  //             LocalizationService.t(context, 'auth.biometric.enable'),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (enable == true && mounted) {
  //     await _storage.setBiometricEnabled(true);
  //   }
  // }

  // Future<void> _signInWithBiometric(BuildContext context) async {
  //   final result = await _biometricService.authenticate(
  //     reason: LocalizationService.t(context, 'auth.biometric.signInReason'),
  //   );
  //   if (!mounted) return;
  //   switch (result) {
  //     case BiometricAuthResult.success:
  //       await AuthService().refreshAuthStatus();
  //       if (context.mounted) context.go(AppRoutes.dashboard);
  //       break;
  //     case BiometricAuthResult.failure:
  //     case BiometricAuthResult.unavailable:
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             LocalizationService.t(context, 'auth.biometric.signInFailed'),
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       break;
  //     case BiometricAuthResult.cancel:
  //       break;
  //   }
  // }

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
                // _maybeShowEnableBiometricDialog(context).then((_) {
                //   if (context.mounted) {
                //     context.go(AppRoutes.dashboard);
                //   }
                // });
                if (context.mounted) context.go(AppRoutes.dashboard);
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
                        // Biometric login option commented out for now
                        // if (_showBiometricLogin) ...[
                        //   SizedBox(
                        //     width: double.infinity,
                        //     child: OutlinedButton.icon(
                        //       onPressed: isLoading
                        //           ? null
                        //           : () => _signInWithBiometric(context),
                        //       icon: const Icon(Icons.fingerprint, size: 24),
                        //       label: Text(
                        //         LocalizationService.t(
                        //           context,
                        //           'auth.biometric.signInWith',
                        //         ),
                        //       ),
                        //       style: OutlinedButton.styleFrom(
                        //         foregroundColor: AppColors.primary,
                        //         side: const BorderSide(color: AppColors.primary),
                        //         shape: const StadiumBorder(),
                        //         padding: const EdgeInsets.symmetric(
                        //           vertical: Spacing.md,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        //   const SizedBox(height: Spacing.lg),
                        //   Row(
                        //     children: <Widget>[
                        //       Expanded(child: Divider(color: Colors.grey[300])),
                        //       Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: Spacing.md,
                        //         ),
                        //         child: Text(
                        //           LocalizationService.t(context, 'auth.login.or'),
                        //           style: Theme.of(context)
                        //               .textTheme
                        //               .bodyMedium
                        //               ?.copyWith(color: Colors.grey[600]),
                        //         ),
                        //       ),
                        //       Expanded(child: Divider(color: Colors.grey[300])),
                        //     ],
                        //   ),
                        //   const SizedBox(height: Spacing.lg),
                        // ],
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
                        const SizedBox(height: Spacing.sm),
                        // Remember me checkbox
                        Row(
                          children: <Widget>[
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: Spacing.xs),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: Text(
                                LocalizationService.t(
                                  context,
                                  'auth.login.rememberMe',
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                            ),
                          ],
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
                                          rememberMe: _rememberMe,
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
                        // const SizedBox(height: Spacing.md),
                        // SocialLoginButton(
                        //   type: SocialLoginType.facebook,
                        //   onPressed: () {
                        //     // TODO: Handle Facebook login
                        //   },
                        // ),
                        const SizedBox(height: Spacing.xxl),
                        // Sign up link
                        SignUpLink(
                          onTap: () {
                            context.push(AppRoutes.signup);
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                        // Become Affiliate Partner button
                        Center(
                          child: TextButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.push(
                                      AppRoutes.affiliateRegister,
                                      extra: () {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                LocalizationService.t(
                                                  context,
                                                  'affiliate.registrationSuccessMessage',
                                                ),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                            icon: Icon(
                              Icons.star_outline,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              LocalizationService.t(
                                context,
                                'affiliate.becomeAffiliatePartner',
                              ),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
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
