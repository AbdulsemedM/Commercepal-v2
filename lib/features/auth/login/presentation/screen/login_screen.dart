import 'package:commercepal/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/core/utils/phone_utils.dart';
import 'package:commercepal/core/auth/remember_me_crypto.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/biometric_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LoginMethod _loginMethod = LoginMethod.email;
  String _completePhoneNumber = '';
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
        _phoneController.clear();
        _completePhoneNumber = '';
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
      );
    }
    if (!mounted) return;
    setState(() {
      _needsBiometricToRevealSavedLogin = false;
      _showUnlockSavedLoginButton = false;
      if (email != null && email.isNotEmpty) {
        _applySavedIdentifier(email);
      }
      if (password != null && password.isNotEmpty) {
        _passwordController.text = password;
        _rememberMe = true;
      } else if (email != null && email.isNotEmpty) {
        _rememberMe = true;
      }
    });
  }

  void _applySavedIdentifier(String identifier) {
    if (PhoneUtils.looksLikePhone(identifier)) {
      final String normalized = PhoneUtils.normalizeLoginIdentifier(identifier);
      _loginMethod = LoginMethod.phone;
      _completePhoneNumber = normalized;
      if (normalized.startsWith('251') && normalized.length >= 12) {
        _phoneController.text = normalized.substring(3);
      } else {
        _phoneController.text = identifier.replaceAll(RegExp(r'\D'), '');
      }
      _emailController.clear();
    } else {
      _loginMethod = LoginMethod.email;
      _emailController.text = identifier;
      _phoneController.clear();
      _completePhoneNumber = '';
    }
  }

  Future<void> _applyDecryptedSavedCredentials() async {
    final String? email = await _storage.getRememberedEmail();
    final String? cipher = await _storage.getRememberedPasswordCipher();
    if (cipher == null || cipher.isEmpty) return;
    final String? password = await RememberMeCrypto.tryDecryptPassword(
      _storage,
      cipher,
    );
    if (!mounted) return;
    if (password == null || password.isEmpty) {
      AppSnackbars.error(context, LocalizationService.t(context, 'auth.biometric.signInFailed'));
      setState(() {
        _needsBiometricToRevealSavedLogin = false;
        _showUnlockSavedLoginButton = false;
      });
      return;
    }
    setState(() {
      if (email != null && email.isNotEmpty) {
        _applySavedIdentifier(email);
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
        AppSnackbars.error(context, LocalizationService.t(context, 'auth.biometric.signInFailed'));
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
          _phoneController.clear();
          _completePhoneNumber = '';
          _loginMethod = LoginMethod.email;
        });
      }
    }
  }

  String _resolveLoginIdentifier() {
    if (_loginMethod == LoginMethod.email) {
      return _emailController.text.trim();
    }
    final String raw = _completePhoneNumber.isNotEmpty
        ? _completePhoneNumber
        : _phoneController.text.trim();
    return PhoneUtils.normalizeLoginIdentifier(raw);
  }

  void _submitLogin(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;

    final String loginIdentifier = _resolveLoginIdentifier();
    if (_loginMethod == LoginMethod.phone &&
        !PhoneUtils.isValidLoginIdentifier(loginIdentifier)) {
      AppSnackbars.error(context, LocalizationService.t(context, 'auth.login.phoneInvalid'));
      return;
    }

    context.read<LoginBloc>().add(
          LoginSubmitted(
            loginIdentifier: loginIdentifier,
            password: _passwordController.text,
            channel: PlatformUtils.getAuthChannel(),
            rememberMe: _rememberMe,
            usedPhoneLogin: _loginMethod == LoginMethod.phone,
          ),
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
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
        AppSnackbars.error(context, LocalizationService.t(context, 'auth.biometric.signInFailed'));
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
          // Embedded in the dashboard profile tab — do not rewrite the route
          // (that would look like a forced redirect away from Cart/Home).
          if (widget.hideBackButton) return;
          _goToDashboardProfileTab();
        },
        child: Scaffold(
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
                  String message = state.message;
                  if (state.isInvalidCredentials) {
                    message = LocalizationService.t(
                      context,
                      state.usedPhoneLogin
                          ? 'auth.login.invalidCredentialsPhone'
                          : 'auth.login.invalidCredentialsEmail',
                    );
                  }
                  AppSnackbars.error(context, message);
                }
              },
              child: BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  final isLoading = state is LoginLoading;
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
                                if (!widget.hideBackButton) ...[
                                  const SizedBox(height: Spacing.md),
                                  // Back button
                                  AuthBackButton(
                                      onPressed: _goToDashboardProfileTab),
                                ] else
                                  const SizedBox(height: Spacing.lg),
                                const SizedBox(height: Spacing.sm),
                                // Title
                                Semantics(
                                  header: true,
                                  child: Text(
                                    LocalizationService.t(
                                        context, 'auth.login.title'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ),
                                const SizedBox(height: Spacing.xs),
                                // Subtitle
                                Text(
                                  LocalizationService.t(
                                      context, 'auth.login.subtitle'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: scheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: Spacing.lg),
                                LoginMethodTabs(
                                  selected: _loginMethod,
                                  onChanged: (LoginMethod method) {
                                    setState(() {
                                      _loginMethod = method;
                                    });
                                  },
                                ),
                                const SizedBox(height: Spacing.lg),
                                if (_showBiometricLogin) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: isLoading
                                          ? null
                                          : () => _signInWithBiometric(),
                                      icon: const Icon(Icons.fingerprint,
                                          size: 24),
                                      label: Text(
                                        LocalizationService.t(
                                          context,
                                          'auth.biometric.signInWith',
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: scheme.primary,
                                        side: BorderSide(color: scheme.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.lg),
                                  const _OrDivider(),
                                  const SizedBox(height: Spacing.lg),
                                ],
                                if (_needsBiometricToRevealSavedLogin ||
                                    _showUnlockSavedLoginButton) ...[
                                  _StoredCredentialsBiometricCard(
                                    isLoading: isLoading,
                                    onTap:
                                        _presentBiometricAndApplySavedCredentials,
                                  ),
                                  const SizedBox(height: Spacing.lg),
                                  const _OrDivider(),
                                  const SizedBox(height: Spacing.lg),
                                ],
                                if (_loginMethod == LoginMethod.email)
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
                                const SizedBox(height: Spacing.md),
                                // Password field
                                PasswordInputField(
                                  controller: _passwordController,
                                  onSubmitted: (_) {
                                    if (!isLoading) _submitLogin(context);
                                  },
                                ),
                                const SizedBox(height: Spacing.xs),
                                // Remember me (whole label tappable) + forgot
                                // password on one row.
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: MergeSemantics(
                                        child: InkWell(
                                          borderRadius: AppRadius.smAll,
                                          onTap: () => setState(
                                            () => _rememberMe = !_rememberMe,
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Checkbox(
                                                value: _rememberMe,
                                                onChanged: (bool? value) =>
                                                    setState(
                                                  () => _rememberMe =
                                                      value ?? false,
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  LocalizationService.t(
                                                    context,
                                                    'auth.login.rememberMe',
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    ForgotPasswordLink(
                                      onTap: () {
                                        context.push(AppRoutes.forgotPassword);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Spacing.lg),
                                AuthPrimaryButton(
                                  label: LocalizationService.t(
                                    context,
                                    'auth.login.loginButton',
                                  ),
                                  isLoading: isLoading,
                                  onPressed: () => _submitLogin(context),
                                ),
                                if (PlatformUtils
                                    .shouldShowGoogleSignInButton) ...[
                                  const SizedBox(height: Spacing.md),
                                  // Or separator
                                  const _OrDivider(),
                                  const SizedBox(height: Spacing.xl),
                                  SocialLoginButton(
                                    type: SocialLoginType.google,
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.read<LoginBloc>().add(
                                                  GoogleSignInRequested(
                                                    channel: PlatformUtils
                                                        .getGoogleSignInChannel(),
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
                                ],
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
                                                  AppSnackbars.success(
                                                    context,
                                                    LocalizationService.t(
                                                      context,
                                                      'affiliate.registrationSuccessMessage',
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                    icon: Icon(
                                      Icons.handshake_outlined,
                                      size: 20,
                                      color: context.commerce.deal,
                                    ),
                                    label: Text(
                                      LocalizationService.t(
                                        context,
                                        'affiliate.becomeAffiliatePartner',
                                      ),
                                    ),
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
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Text(
            LocalizationService.t(context, 'auth.login.or'),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const Expanded(child: Divider()),
      ],
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: InkWell(
        onTap: isLoading ? null : () => onTap(),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.commerce.cta,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  FontAwesomeIcons.fingerprint,
                  size: 26,
                  color: context.commerce.onCta,
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocalizationService.t(
                        context,
                        'auth.biometric.unlockSavedLoginHint',
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
