import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/core/auth/remember_me_crypto.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/biometric_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final BiometricService _biometricService = BiometricService();
  bool _showBiometricLogin = false;
  bool _needsBiometricToRevealSavedLogin = false;
  bool _showUnlockSavedLoginButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await _maybeShowPostLogoutRememberDialog();
      if (mounted) await _prefillFromRememberMe();
      if (mounted) await _checkBiometricLoginAvailable();
    });
  }

  Future<void> _checkBiometricLoginAvailable() async {
    final biometricEnabled = await _storage.getBiometricEnabled();
    final hasTokens = await _storage.hasTokens();
    if (mounted && biometricEnabled && hasTokens) {
      setState(() => _showBiometricLogin = true);
    }
  }

  Future<void> _prefillFromRememberMe() async {
    final String? email = await _storage.getRememberedEmail();
    final String? savedCipher = await _storage.getRememberedPasswordCipher();
    final String? bound = await _storage.getRememberMeBoundDeviceId();
    final bool biometricOn = await _storage.getBiometricEnabled();
    final bool enrolled = await _biometricService.hasEnrolledBiometrics;
    final bool gateSavedLoginWithBio = savedCipher != null &&
        savedCipher.isNotEmpty &&
        biometricOn &&
        enrolled;

    if (gateSavedLoginWithBio) {
      if (!mounted) return;
      setState(() {
        _emailController.clear();
        _passwordController.clear();
        _needsBiometricToRevealSavedLogin = true;
        _showUnlockSavedLoginButton = false;
      });
      return;
    }

    String? password;
    if (savedCipher != null && savedCipher.isNotEmpty) {
      password = await RememberMeCrypto.tryDecryptPassword(
        _storage,
        savedCipher,
        bound,
      );
    }
    if (!mounted) return;
    setState(() {
      _needsBiometricToRevealSavedLogin = false;
      _showUnlockSavedLoginButton = false;
      if (email != null && email.isNotEmpty) {
        _emailController.text = email;
      }
      if (password != null && password.isNotEmpty) {
        _passwordController.text = password;
        _rememberMe = true;
      } else if (email != null && email.isNotEmpty) {
        _rememberMe = true;
      }
    });
  }

  Future<void> _applyDecryptedSavedCredentials() async {
    final String? email = await _storage.getRememberedEmail();
    final String? cipher = await _storage.getRememberedPasswordCipher();
    final String? bound = await _storage.getRememberMeBoundDeviceId();
    if (cipher == null || cipher.isEmpty) return;
    final String? password = await RememberMeCrypto.tryDecryptPassword(
      _storage,
      cipher,
      bound,
    );
    if (!mounted) return;
    if (password == null || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.t(context, 'auth.biometric.signInFailed'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _needsBiometricToRevealSavedLogin = false;
        _showUnlockSavedLoginButton = false;
      });
      return;
    }
    setState(() {
      if (email != null && email.isNotEmpty) {
        _emailController.text = email;
      }
      _passwordController.text = password;
      _rememberMe = true;
      _needsBiometricToRevealSavedLogin = false;
      _showUnlockSavedLoginButton = false;
    });
  }

  Future<void> _presentBiometricAndApplySavedCredentials() async {
    if (!mounted) return;
    final BiometricAuthResult result = await _biometricService.authenticate(
      reason: LocalizationService.t(
        context,
        'auth.biometric.unlockSavedLoginReason',
      ),
    );
    if (!mounted) return;
    switch (result) {
      case BiometricAuthResult.success:
        await _applyDecryptedSavedCredentials();
        break;
      case BiometricAuthResult.failure:
      case BiometricAuthResult.unavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.t(context, 'auth.biometric.signInFailed'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _showUnlockSavedLoginButton = true);
        break;
      case BiometricAuthResult.cancel:
        setState(() => _showUnlockSavedLoginButton = true);
        break;
    }
  }

  Future<void> _maybeShowPostLogoutRememberDialog() async {
    final bool justLoggedOut = await _storage.getJustLoggedOut();
    if (!justLoggedOut || !mounted) return;

    final bool? rememberNextTime = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          LocalizationService.t(
            dialogContext,
            'auth.rememberMe.afterLogoutTitle',
          ),
        ),
        content: Text(
          LocalizationService.t(
            dialogContext,
            'auth.rememberMe.afterLogoutMessage',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              LocalizationService.t(
                dialogContext,
                'auth.rememberMe.afterLogoutNo',
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              LocalizationService.t(
                dialogContext,
                'auth.rememberMe.afterLogoutYes',
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    await _storage.setJustLoggedOut(false);

    if (rememberNextTime == true) {
      setState(() => _rememberMe = true);
    } else if (rememberNextTime == false) {
      await _storage.clearRememberMeCredentials();
      await _storage.clearRememberedEmail();
      if (mounted) {
        setState(() {
          _rememberMe = false;
          _passwordController.clear();
          _emailController.clear();
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _maybeShowEnableBiometricDialog() async {
    final hasBiometrics = await _biometricService.hasEnrolledBiometrics;
    final alreadyEnabled = await _storage.getBiometricEnabled();
    if (!mounted || !hasBiometrics || alreadyEnabled) return;

    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          LocalizationService.t(dialogContext, 'auth.biometric.enableTitle'),
        ),
        content: Text(
          LocalizationService.t(
            dialogContext,
            'auth.biometric.enableMessage',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              LocalizationService.t(dialogContext, 'auth.biometric.notNow'),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              LocalizationService.t(dialogContext, 'auth.biometric.enable'),
            ),
          ),
        ],
      ),
    );

    if (enable == true && mounted) {
      await _storage.setBiometricEnabled(true);
    }
  }

  Future<void> _signInWithBiometric() async {
    if (!mounted) return;
    final result = await _biometricService.authenticate(
      reason: LocalizationService.t(context, 'auth.biometric.signInReason'),
    );
    if (!mounted) return;
    switch (result) {
      case BiometricAuthResult.success:
        await AuthService().refreshAuthStatus();
        if (!mounted) return;
        context.go(AppRoutes.dashboard);
        break;
      case BiometricAuthResult.failure:
      case BiometricAuthResult.unavailable:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.t(context, 'auth.biometric.signInFailed'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        break;
      case BiometricAuthResult.cancel:
        break;
    }
  }

  void _goToDashboardProfileTab() {
    context.go('${AppRoutes.dashboard}?tab=3');
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _goToDashboardProfileTab();
        },
        child: Scaffold(
          backgroundColor: scheme.surface,
          body: SafeArea(
            child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                _maybeShowEnableBiometricDialog().then((_) {
                  if (context.mounted) {
                    context.go(AppRoutes.dashboard);
                  }
                });
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
                                color: scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: scheme.onSurface,
                              ),
                            ),
                            onPressed: _goToDashboardProfileTab,
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
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: Spacing.lg),
                        if (_showBiometricLogin) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => _signInWithBiometric(),
                              icon: const Icon(Icons.fingerprint, size: 24),
                              label: Text(
                                LocalizationService.t(
                                  context,
                                  'auth.biometric.signInWith',
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: Spacing.md,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          Row(
                            children: <Widget>[
                              Expanded(child: Divider(color: scheme.outlineVariant)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                ),
                                child: Text(
                                  LocalizationService.t(
                                    context,
                                    'auth.login.or',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ),
                              Expanded(child: Divider(color: scheme.outlineVariant)),
                            ],
                          ),
                          const SizedBox(height: Spacing.lg),
                        ],
                        if (_needsBiometricToRevealSavedLogin ||
                            _showUnlockSavedLoginButton) ...[
                          _StoredCredentialsBiometricCard(
                            isLoading: isLoading,
                            onTap: _presentBiometricAndApplySavedCredentials,
                          ),
                          const SizedBox(height: Spacing.lg),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(color: scheme.outlineVariant),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                ),
                                child: Text(
                                  LocalizationService.t(
                                    context,
                                    'auth.login.or',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: scheme.outlineVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.lg),
                        ],
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
                                    ?.copyWith(color: scheme.onSurface),
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
                              disabledBackgroundColor: scheme.surfaceContainerHighest,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.onPrimary,
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
                                              color: scheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(width: Spacing.xs),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 20,
                                        color: scheme.onPrimary,
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
                                color: scheme.outlineVariant,
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
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: scheme.outlineVariant,
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
      ),
    );
  }
}

class _StoredCredentialsBiometricCard extends StatelessWidget {
  const _StoredCredentialsBiometricCard({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                onTap();
              },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: scheme.surfaceContainerHighest,
            border: Border.all(color: scheme.outline),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.82),
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const FaIcon(
                    FontAwesomeIcons.fingerprint,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        LocalizationService.t(
                          context,
                          'auth.biometric.unlockSavedLogin',
                        ),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        LocalizationService.t(
                          context,
                          'auth.biometric.unlockSavedLoginHint',
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 28,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
