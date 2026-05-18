import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/phone_utils.dart';
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            children: <TextSpan>[
              TextSpan(
                text: LocalizationService.t(context, 'auth.login.phone'),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(color: scheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs),
        IntlPhoneField(
          controller: controller,
          initialCountryCode: 'ET',
          flagsButtonPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
          ),
          dropdownIconPosition: IconPosition.trailing,
          decoration: InputDecoration(
            hintText: LocalizationService.t(
              context,
              'auth.login.phonePlaceholder',
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
            ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface,
          ),
          onChanged: (PhoneNumber phone) {
            onCompleteNumberChanged?.call(phone.completeNumber);
          },
          validator:
              validator ??
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          LocalizationService.t(context, 'auth.login.email'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: LocalizationService.t(
              context,
              'auth.login.emailPlaceholder',
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
            ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          LocalizationService.t(context, 'auth.login.password'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: LocalizationService.t(
              context,
              'auth.login.passwordPlaceholder',
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
            ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
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
                color: scheme.onSurfaceVariant,
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
