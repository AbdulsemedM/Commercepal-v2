import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/phone_utils.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/services/localization_service.dart';

enum LoginMethod { email, phone }

/// Shared validators so login, signup and password screens agree.
class AuthValidators {
  AuthValidators._();

  static FormFieldValidator<String> email(BuildContext context) =>
      (String? value) {
        final String v = (value ?? '').trim();
        if (v.isEmpty) return context.tr('validation.emailRequired');
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
          return context.tr('validation.emailInvalid');
        }
        return null;
      };

  static FormFieldValidator<String> password(
    BuildContext context, {
    int min = 6,
  }) =>
      (String? value) {
        if (value == null || value.isEmpty) {
          return context.tr('validation.passwordRequired');
        }
        if (value.length < min) {
          return context.tr('validation.passwordMin', <String, Object?>{
            'min': min,
          });
        }
        return null;
      };
}

/// Email / Phone segmented switch for login.
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
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (LoginMethod m, IconData icon, String key)
              in <(LoginMethod, IconData, String)>[
            (LoginMethod.email, Icons.mail_outline_rounded, 'auth.login.tabEmail'),
            (LoginMethod.phone, Icons.phone_iphone_rounded, 'auth.login.tabPhone'),
          ])
            Expanded(
              child: _LoginMethodTab(
                label: context.tr(key),
                icon: icon,
                isSelected: selected == m,
                onTap: () {
                  if (selected != m) HapticFeedback.selectionClick();
                  onChanged(m);
                },
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
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color fg = isSelected ? scheme.onSurface : scheme.onSurfaceVariant;
    return Semantics(
      selected: isSelected,
      button: true,
      inMutuallyExclusiveGroup: true,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          color: isSelected ? scheme.surface : Colors.transparent,
          borderRadius: AppRadius.pillAll,
          boxShadow: isSelected ? AppShadows.sm(scheme.brightness) : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: isSelected ? scheme.primary : fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
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
          context.tr('auth.login.phone'),
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        // Phone numbers are always LTR, even in Arabic.
        Directionality(
          textDirection: TextDirection.ltr,
          child: IntlPhoneField(
            controller: controller,
            initialCountryCode: 'ET',
            flagsButtonPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
            ),
            dropdownIconPosition: IconPosition.trailing,
            disableLengthCheck: false,
            textInputAction: TextInputAction.next,
            decoration: authFieldDecoration(
              context,
              hintText: context.tr('auth.login.phonePlaceholder'),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            pickerDialogStyle: PickerDialogStyle(
              backgroundColor: Theme.of(context).colorScheme.surface,
              searchFieldInputDecoration: InputDecoration(
                hintText: context.tr('auth.searchCountry'),
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            onChanged: (PhoneNumber phone) {
              onCompleteNumberChanged?.call(phone.completeNumber);
            },
            validator: validator ??
                (PhoneNumber? phone) {
                  if (phone == null || phone.number.isEmpty) {
                    return context.tr('auth.login.phoneRequired');
                  }
                  final String normalized =
                      PhoneUtils.normalizeLoginIdentifier(phone.completeNumber);
                  if (!PhoneUtils.isValidLoginIdentifier(normalized)) {
                    return context.tr('auth.login.phoneInvalid');
                  }
                  return null;
                },
            invalidNumberMessage: context.tr('auth.login.phoneInvalid'),
          ),
        ),
      ],
    );
  }
}

/// Email input field.
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
    return AuthTextField(
      label: context.tr('auth.login.email'),
      hintText: context.tr('auth.login.emailPlaceholder'),
      controller: controller,
      onChanged: onChanged,
      validator: validator ?? AuthValidators.email(context),
      keyboardType: TextInputType.emailAddress,
      autofillHints: const <String>[AutofillHints.email, AutofillHints.username],
      textInputAction: TextInputAction.next,
    );
  }
}

/// Password input with visibility toggle.
class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    super.key,
    this.controller,
    this.onChanged,
    this.validator,
    this.label,
    this.hintText,
    this.isNewPassword = false,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? label;
  final String? hintText;

  /// Offers password-manager generation instead of fill.
  final bool isNewPassword;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

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
          widget.label ?? context.tr('auth.login.password'),
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator ?? AuthValidators.password(context),
          obscureText: _obscureText,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: widget.textInputAction,
          autofillHints: <String>[
            widget.isNewPassword
                ? AutofillHints.newPassword
                : AutofillHints.password,
          ],
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: authFieldDecoration(
            context,
            hintText:
                widget.hintText ?? context.tr('auth.login.passwordPlaceholder'),
            suffixIcon: IconButton(
              tooltip: context.tr(
                _obscureText ? 'auth.showPassword' : 'auth.hidePassword',
              ),
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
        ),
      ],
    );
  }
}

/// Social login button.
enum SocialLoginType { google, facebook, apple }

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({super.key, required this.type, this.onPressed});

  final SocialLoginType type;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool dark = theme.brightness == Brightness.dark;

    // Brand colours follow each provider's button guidelines.
    final (String label, Color bg, Color fg, String image, BorderSide side) =
        switch (type) {
      SocialLoginType.google => (
          context.tr('auth.login.socialGoogle'),
          scheme.surface,
          scheme.onSurface,
          'assets/images/Google.png',
          BorderSide(color: scheme.outline),
        ),
      SocialLoginType.facebook => (
          context.tr('auth.login.socialFacebook'),
          const Color(0xFF1877F2),
          Colors.white,
          'assets/images/Facebook.png',
          BorderSide.none,
        ),
      SocialLoginType.apple => (
          context.tr('auth.login.socialApple'),
          dark ? Colors.white : Colors.black,
          dark ? Colors.black : Colors.white,
          'assets/images/Apple.png',
          BorderSide.none,
        ),
    };

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonLg,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: side,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              image,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              color: type == SocialLoginType.apple ? fg : null,
            ),
            const SizedBox(width: Spacing.sm),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Forgot your password? Reset it" link.
class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppButton.text(
      label: context.tr('auth.login.forgotPassword'),
      size: AppButtonSize.small,
      onPressed: onTap,
    );
  }
}

/// "Don't have an account? Join" row.
class SignUpLink extends StatelessWidget {
  const SignUpLink({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          context.tr('auth.login.noAccount'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppButton.text(
          label: context.tr('auth.login.join'),
          size: AppButtonSize.small,
          onPressed: onTap,
        ),
      ],
    );
  }
}
