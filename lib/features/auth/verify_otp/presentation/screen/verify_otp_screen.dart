import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.t(context, 'auth.otp.invalid'),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(),
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
                _otpKey.currentState?.clear();
                setState(() {
                  _otp = '';
                  _autoSubmitted = false;
                });
                _startCountdown();
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
                final bool isResending = state is ForgotPasswordLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
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
                      Text(
                        LocalizationService.t(context, 'auth.otp.title'),
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
                        LocalizationService.t(context, 'auth.otp.subtitle')
                            .replaceAll('{target}', widget.target),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: Spacing.xl),
                      OtpPinInput(
                        key: _otpKey,
                        enabled: !isResending,
                        onChanged: (value) {
                          setState(() {
                            _otp = value;
                            _autoSubmitted = false;
                          });
                        },
                        onCompleted: (code) {
                          if (!_autoSubmitted) {
                            _onOtpCompleted(code);
                          }
                        },
                      ),
                      const SizedBox(height: Spacing.lg),
                      AuthPrimaryButton(
                        label: LocalizationService.t(context, 'auth.otp.verify'),
                        onPressed: _isOtpValid ? _onVerify : null,
                        showArrow: false,
                      ),
                      const SizedBox(height: Spacing.lg),
                      Center(
                        child: _secondsRemaining > 0
                            ? Text(
                                LocalizationService.t(
                                  context,
                                  'auth.otp.resendIn',
                                ).replaceAll(
                                  '{seconds}',
                                  '$_secondsRemaining',
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              )
                            : GestureDetector(
                                onTap: isResending
                                    ? null
                                    : () => _resend(context),
                                child: isResending
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        LocalizationService.t(
                                          context,
                                          'auth.otp.resend',
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
                      const SizedBox(height: Spacing.md),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(
                            LocalizationService.t(
                              context,
                              'auth.otp.backToLogin',
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
