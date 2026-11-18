import 'package:commercepal/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/core/utils/phone_utils.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/biometric_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/features/auth/presentation/widgets/otp_pin_input.dart';
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
  final _formKey = GlobalKey<FormState>();
  LoginMethod _loginMethod = LoginMethod.email;
  String _completePhoneNumber = '';
  bool _rememberMe = false;
  final Storage _storage = Storage();
  final BiometricService _biometricService = BiometricService();
  bool _showBiometricLogin = false;

  // Passwordless login: identifier -> code sent -> verify.
  final TextEditingController _nameController = TextEditingController();
  String? _otpSentTo;
  String? _otpIdentifier;
  bool _needsName = false;
  String _otpCode = '';

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

  /// Only the phone/email is remembered — login uses a one-time code now.
  Future<void> _prefillFromRememberMe() async {
    final String? identifier = await _storage.getRememberedEmail();
    if (!mounted || identifier == null || identifier.isEmpty) return;
    setState(() {
      _applySavedIdentifier(identifier);
      _rememberMe = true;
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

  /// Step 1: send a one-time code to the phone/email (no password).
  void _sendCode(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;

    final String loginIdentifier = _resolveLoginIdentifier();
    if (_loginMethod == LoginMethod.phone &&
        !PhoneUtils.isValidLoginIdentifier(loginIdentifier)) {
      AppSnackbars.error(context, LocalizationService.t(context, 'auth.login.phoneInvalid'));
      return;
    }
    if (_needsName && _nameController.text.trim().isEmpty) {
      AppSnackbars.error(context, LocalizationService.t(context, 'auth.otpLogin.nameRequired'));
      return;
    }

    context.read<LoginBloc>().add(
          OtpCodeRequested(
            identifier: loginIdentifier,
            usedPhoneLogin: _loginMethod == LoginMethod.phone,
            firstName: _needsName ? _nameController.text.trim() : null,
          ),
        );
  }

  /// Step 2: verify the code and sign in.
  void _verifyCode(BuildContext context, String code) {
    final String? identifier = _otpIdentifier;
    if (identifier == null || code.length < 6) return;
    context.read<LoginBloc>().add(
          OtpVerifySubmitted(
            identifier: identifier,
            code: code,
            usedPhoneLogin: _loginMethod == LoginMethod.phone,
            rememberMe: _rememberMe,
            channel: PlatformUtils.getAuthChannel(),
          ),
        );
  }

  void _resetOtp() {
    _otpSentTo = null;
    _otpIdentifier = null;
    _otpCode = '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
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
                    if (!context.mounted) return;
                    // Opened from checkout/cart: go back so the purchase continues.
                    if (!widget.hideBackButton && context.canPop()) {
                      context.pop(true);
                    } else {
                      context.go(AppRoutes.dashboard);
                    }
                  });
                } else if (state is OtpCodeSent) {
                  setState(() {
                    _otpSentTo = state.sentTo;
                    _otpIdentifier = state.identifier;
                    _otpCode = '';
                  });
                } else if (state is OtpNameRequired) {
                  setState(() => _needsName = true);
                  AppSnackbars.info(context, state.message);
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
                                      _needsName = false;
                                      _resetOtp();
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
                                if (_needsName && _otpSentTo == null) ...[
                                  const SizedBox(height: Spacing.md),
                                  TextFormField(
                                    controller: _nameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autofillHints: const <String>[
                                      AutofillHints.givenName,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: LocalizationService.t(
                                        context,
                                        'auth.otpLogin.nameLabel',
                                      ),
                                    ),
                                  ),
                                ],
                                if (_otpSentTo != null) ...[
                                  const SizedBox(height: Spacing.lg),
                                  Text(
                                    LocalizationService.tf(
                                      context,
                                      'auth.otpLogin.codeSentTo',
                                      <String, Object?>{
                                        'destination': _otpSentTo,
                                      },
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: Spacing.md),
                                  OtpPinInput(
                                    enabled: !isLoading,
                                    onChanged: (String code) =>
                                        _otpCode = code,
                                    onCompleted: (String code) {
                                      _otpCode = code;
                                      _verifyCode(context, code);
                                    },
                                  ),
                                  const SizedBox(height: Spacing.sm),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => setState(_resetOtp),
                                        child: Text(LocalizationService.t(
                                          context,
                                          'auth.otpLogin.changeNumber',
                                        )),
                                      ),
                                      TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => _sendCode(context),
                                        child: Text(LocalizationService.t(
                                          context,
                                          'auth.otpLogin.resend',
                                        )),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: Spacing.xs),
                                MergeSemantics(
                                  child: InkWell(
                                    borderRadius: AppRadius.smAll,
                                    onTap: () => setState(
                                      () => _rememberMe = !_rememberMe,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (bool? value) => setState(
                                            () => _rememberMe = value ?? false,
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
                                const SizedBox(height: Spacing.lg),
                                AuthPrimaryButton(
                                  label: LocalizationService.t(
                                    context,
                                    _otpSentTo == null
                                        ? 'auth.otpLogin.sendCode'
                                        : 'auth.otpLogin.verify',
                                  ),
                                  isLoading: isLoading,
                                  onPressed: () => _otpSentTo == null
                                      ? _sendCode(context)
                                      : _verifyCode(context, _otpCode),
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
