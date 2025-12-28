import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

/// Email input field widget
class EmailInputField extends StatelessWidget {
  const EmailInputField({
    super.key,
    this.controller,
    this.onChanged,
    this.validator,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          LocalizationService.t(context, 'auth.login.email'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
          keyboardType: TextInputType.emailAddress,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: LocalizationService.t(
              context,
              'auth.login.emailPlaceholder',
            ),
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// Password input field widget with visibility toggle
class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    super.key,
    this.controller,
    this.onChanged,
    this.validator,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          LocalizationService.t(context, 'auth.login.password'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          validator:
              widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
          obscureText: _obscureText,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: LocalizationService.t(
              context,
              'auth.login.passwordPlaceholder',
            ),
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Social login button widget
enum SocialLoginType { google, facebook, apple }

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({super.key, required this.type, this.onPressed});

  final SocialLoginType type;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Map<SocialLoginType, Map<String, dynamic>> buttonConfig = {
      SocialLoginType.google: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.login.socialGoogle'),
        'backgroundColor': Colors.white,
        'textColor': Colors.black,
        'borderColor': Colors.grey[300]!,
        'imagePath': 'assets/images/Google.png',
      },
      SocialLoginType.facebook: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.login.socialFacebook'),
        'backgroundColor': const Color(0xFF1877F2),
        'textColor': Colors.white,
        'borderColor': const Color(0xFF1877F2),
        'imagePath': 'assets/images/Facebook.png',
      },
      SocialLoginType.apple: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.login.socialApple'),
        'backgroundColor': Colors.black,
        'textColor': Colors.white,
        'borderColor': Colors.black,
        'imagePath': 'assets/images/Apple.png',
      },
    };

    final Map<String, dynamic> config = buttonConfig[type]!;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: config['backgroundColor'] as Color,
          side: BorderSide(color: config['borderColor'] as Color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              config['imagePath'] as String,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              config['label'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: config['textColor'] as Color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Forgot password link widget
class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            children: <TextSpan>[
              TextSpan(
                text:
                    '${LocalizationService.t(context, 'auth.login.forgotPassword')} ',
              ),
              TextSpan(
                text: LocalizationService.t(
                  context,
                  'auth.login.resetPassword',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sign up link widget
class SignUpLink extends StatelessWidget {
  const SignUpLink({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            children: <TextSpan>[
              TextSpan(
                text:
                    '${LocalizationService.t(context, 'auth.login.noAccount')} ',
              ),
              TextSpan(
                text: LocalizationService.t(context, 'auth.login.join'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
