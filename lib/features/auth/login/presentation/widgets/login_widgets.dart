import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/phone_utils.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/services/localization_service.dart';

enum LoginMethod { email, phone }

/// Email / Phone segmented tabs for login.
class LoginMethodTabs extends StatelessWidget {
  const LoginMethodTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final LoginMethod selected;
  final ValueChanged<LoginMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppDecorations.softCream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _LoginMethodTab(
              label: LocalizationService.t(context, 'auth.login.tabEmail'),
              isSelected: selected == LoginMethod.email,
              onTap: () => onChanged(LoginMethod.email),
            ),
          ),
          Expanded(
            child: _LoginMethodTab(
              label: LocalizationService.t(context, 'auth.login.tabPhone'),
              isSelected: selected == LoginMethod.phone,
              onTap: () => onChanged(LoginMethod.phone),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginMethodTab extends StatelessWidget {
  const _LoginMethodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm + 2),
          decoration: BoxDecoration(
            gradient: isSelected ? AppDecorations.primaryCtaGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.pink.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

/// Phone number input for login (international, Ethiopia default).
class PhoneLoginInputField extends StatelessWidget {
  const PhoneLoginInputField({
    super.key,
    this.controller,
    this.onCompleteNumberChanged,
    this.validator,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onCompleteNumberChanged;
  final FormFieldValidator<PhoneNumber>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          LocalizationService.t(context, 'auth.login.phone'),
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        IntlPhoneField(
          controller: controller,
          initialCountryCode: 'ET',
          flagsButtonPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
          ),
          dropdownIconPosition: IconPosition.trailing,
          decoration: authFieldDecoration(
            context,
            hintText: LocalizationService.t(
              context,
              'auth.login.phonePlaceholder',
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.navy,
              ),
          onChanged: (PhoneNumber phone) {
            onCompleteNumberChanged?.call(phone.completeNumber);
          },
          validator: validator ??
              (PhoneNumber? phone) {
                if (phone == null || phone.number.isEmpty) {
                  return LocalizationService.t(
                    context,
                    'auth.login.phoneRequired',
                  );
                }
                final String normalized = PhoneUtils.normalizeLoginIdentifier(
                  phone.completeNumber,
                );
                if (!PhoneUtils.isValidLoginIdentifier(normalized)) {
                  return LocalizationService.t(
                    context,
                    'auth.login.phoneInvalid',
                  );
                }
                return null;
              },
          searchText: 'Search country',
          invalidNumberMessage: LocalizationService.t(
            context,
            'auth.login.phoneInvalid',
          ),
        ),
      ],
    );
  }
}

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
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator ??
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.navy,
              ),
          decoration: authFieldDecoration(
            context,
            hintText: LocalizationService.t(
              context,
              'auth.login.emailPlaceholder',
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
    this.label,
    this.hintText,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? label;
  final String? hintText;

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
          widget.label ??
              LocalizationService.t(context, 'auth.login.password'),
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          validator: widget.validator ??
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.navy,
              ),
          decoration: authFieldDecoration(
            context,
            hintText: widget.hintText ??
                LocalizationService.t(
                  context,
                  'auth.login.passwordPlaceholder',
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
        'textColor': AppColors.navy,
        'imagePath': 'assets/images/Google.png',
      },
      SocialLoginType.facebook: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.login.socialFacebook'),
        'backgroundColor': const Color(0xFF1877F2),
        'textColor': Colors.white,
        'imagePath': 'assets/images/Facebook.png',
      },
      SocialLoginType.apple: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.login.socialApple'),
        'backgroundColor': Colors.black,
        'textColor': Colors.white,
        'imagePath': 'assets/images/Apple.png',
      },
    };

    final Map<String, dynamic> config = buttonConfig[type]!;
    final bool isGoogle = type == SocialLoginType.google;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: config['backgroundColor'] as Color,
        borderRadius: BorderRadius.circular(28),
        elevation: 0,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: isGoogle ? AppDecorations.softCardShadow() : null,
              border: isGoogle
                  ? Border.all(color: const Color(0xFFF0E6D8))
                  : null,
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
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
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
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
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
                      color: AppColors.pink,
                      fontWeight: FontWeight.w700,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            children: <TextSpan>[
              TextSpan(
                text:
                    '${LocalizationService.t(context, 'auth.login.noAccount')} ',
              ),
              TextSpan(
                text: LocalizationService.t(context, 'auth.login.join'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.pink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
