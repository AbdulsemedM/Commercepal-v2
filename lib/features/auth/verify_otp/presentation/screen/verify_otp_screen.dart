import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/features/auth/presentation/widgets/otp_pin_input.dart';
import 'package:commercepal/services/localization_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.target});

  final String target;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final GlobalKey<OtpPinInputState> _otpKey = GlobalKey<OtpPinInputState>();
  String _otp = '';
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _autoSubmitted = false;
  bool _showOtpError = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  bool get _isOtpValid => RegExp(r'^\d{6}$').hasMatch(_otp);

  void _goToNewPassword(String code) {
    if (!_isOtpValid && !RegExp(r'^\d{6}$').hasMatch(code)) return;
    context.push(
      Uri(
        path: AppRoutes.resetPassword,
        queryParameters: <String, String>{
          'target': widget.target,
          'token': code,
        },
      ).toString(),
    );
  }

  void _onOtpCompleted(String code) {
    setState(() {
      _otp = code;
      _autoSubmitted = true;
    });
    _goToNewPassword(code);
  }

  void _onVerify() {
    final code = _otpKey.currentState?.code ?? _otp;
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _showOtpError = true);
      AppSnackbars.error(context, context.tr('auth.otp.invalid'));
      return;
    }
    _goToNewPassword(code);
  }

  void _resend(BuildContext context) {
    if (_secondsRemaining > 0) return;
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordSubmitted(
            emailOrPhone: widget.target,
            channel: PlatformUtils.getChannel(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                AppSnackbars.success(context, state.message);
                _otpKey.currentState?.clear();
                setState(() {
                  _otp = '';
                  _autoSubmitted = false;
                  _showOtpError = false;
                });
                _startCountdown();
              } else if (state is ForgotPasswordFailure) {
                AppSnackbars.error(context, state.message);
              }
            },
            child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
              builder: (context, state) {
                final bool isResending = state is ForgotPasswordLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: Spacing.md),
                            AuthBackButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.forgotPassword);
                                }
                              },
                            ),
                            const SizedBox(height: Spacing.sm),
                            Semantics(
                              header: true,
                              child: Text(
                                context.tr('auth.otp.title'),
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              context.tr('auth.otp.subtitle', <String, Object?>{
                                'target': widget.target,
                              }),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: Spacing.xl),
                            OtpPinInput(
                              key: _otpKey,
                              enabled: !isResending,
                              hasError: _showOtpError,
                              onChanged: (value) {
                                setState(() {
                                  _otp = value;
                                  _autoSubmitted = false;
                                  _showOtpError = false;
                                });
                              },
                              onCompleted: (code) {
                                if (!_autoSubmitted) {
                                  _onOtpCompleted(code);
                                }
                              },
                            ),
                            if (_showOtpError) ...<Widget>[
                              const SizedBox(height: Spacing.xs),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  context.tr('auth.otp.invalid'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.error,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: Spacing.xl),
                            AuthPrimaryButton(
                              label: context.tr('auth.otp.verify'),
                              onPressed: _isOtpValid ? _onVerify : null,
                              showArrow: false,
                            ),
                            const SizedBox(height: Spacing.md),
                            _ResendRow(
                              secondsRemaining: _secondsRemaining,
                              isResending: isResending,
                              onResend: () => _resend(context),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Center(
                              child: AppButton.text(
                                label: context.tr('auth.otp.backToLogin'),
                                onPressed: () => context.go(AppRoutes.login),
                              ),
                            ),
                            const SizedBox(height: Spacing.xl),
                          ],
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

/// Countdown while the resend cooldown runs, then a text button.
class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.secondsRemaining,
    required this.isResending,
    required this.onResend,
  });

  final int secondsRemaining;
  final bool isResending;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: AppSizes.minTouchTarget,
      child: Center(
        child: secondsRemaining > 0
            ? Text(
                context.tr('auth.otp.resendIn', <String, Object?>{
                  'seconds': secondsRemaining,
                }),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              )
            : AppButton.text(
                label: context.tr('auth.otp.resend'),
                icon: Icons.refresh_rounded,
                loading: isResending,
                onPressed: isResending ? null : onResend,
              ),
      ),
    );
  }
}
