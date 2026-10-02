import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';

/// Full name input field widget
class FullNameInputField extends StatelessWidget {
  const FullNameInputField({super.key, this.controller, this.onChanged});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.tr('auth.signup.fullName'),
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.name],
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: authFieldDecoration(
            context,
            hintText: context.tr('auth.signup.fullNamePlaceholder'),
          ),
        ),
      ],
    );
  }
}

/// Date of birth input field widget with date picker
class DateOfBirthInputField extends StatefulWidget {
  const DateOfBirthInputField({super.key, this.controller, this.onChanged});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  State<DateOfBirthInputField> createState() => _DateOfBirthInputFieldState();
}

class _DateOfBirthInputFieldState extends State<DateOfBirthInputField> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // The picker inherits the app theme, so it follows light and dark mode.
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? now.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: context.tr('auth.signup.dateOfBirth'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        final String formattedDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        widget.controller?.text = formattedDate;
        widget.onChanged?.call(formattedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.tr('auth.signup.dateOfBirth'),
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        TextField(
          controller: widget.controller,
          readOnly: true,
          onTap: () => _selectDate(context),
          autofillHints: const <String>[AutofillHints.birthday],
          style: theme.textTheme.bodyLarge?.copyWith(
            fontFeatures: AppTypography.tabularFigures,
          ),
          decoration: authFieldDecoration(
            context,
            hintText: context.tr('auth.signup.dateOfBirthPlaceholder'),
            suffixIcon: IconButton(
              tooltip: context.tr('auth.signup.pickDate'),
              icon: Icon(
                Icons.calendar_today_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _selectDate(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Terms and Privacy Policy text widget with clickable links.
///
/// The sentence is one translatable template (`auth.signup.termsAgreement`)
/// with `{terms}`, `{privacy}` and `{refund}` slots, so each language can
/// order the links naturally.
class TermsAndPolicyText extends StatefulWidget {
  const TermsAndPolicyText({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onPolicyTap,
  });

  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onPolicyTap;

  @override
  State<TermsAndPolicyText> createState() => _TermsAndPolicyTextState();
}

class _TermsAndPolicyTextState extends State<TermsAndPolicyText> {
  final TapGestureRecognizer _terms = TapGestureRecognizer();
  final TapGestureRecognizer _privacy = TapGestureRecognizer();
  final TapGestureRecognizer _refund = TapGestureRecognizer();

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    _refund.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    _terms.onTap = widget.onTermsTap ??
        () => context.push(AppRoutes.termsConditions);
    _privacy.onTap = widget.onPrivacyTap ??
        () => context.push(AppRoutes.termsConditions);
    _refund.onTap =
        widget.onPolicyTap ?? () => context.push(AppRoutes.refundPolicy);

    final TextStyle? linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: scheme.primary,
    );
    final Map<String, (String, TapGestureRecognizer)> links =
        <String, (String, TapGestureRecognizer)>{
      'terms': (context.tr('auth.signup.termsLink'), _terms),
      'privacy': (context.tr('auth.signup.privacyLink'), _privacy),
      'refund': (context.tr('auth.signup.refundLink'), _refund),
    };

    final String template = context.tr('auth.signup.termsAgreement');
    final List<InlineSpan> spans = <InlineSpan>[];
    int cursor = 0;
    for (final RegExpMatch m
        in RegExp(r'\{(terms|privacy|refund)\}').allMatches(template)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: template.substring(cursor, m.start)));
      }
      final (String label, TapGestureRecognizer recognizer) = links[m[1]]!;
      spans.add(
        TextSpan(text: label, style: linkStyle, recognizer: recognizer),
      );
      cursor = m.end;
    }
    if (cursor < template.length) {
      spans.add(TextSpan(text: template.substring(cursor)));
    }

    return Text.rich(
      TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        children: spans,
      ),
    );
  }
}

/// Email input field widget for signup
class SignupEmailInputField extends StatelessWidget {
  const SignupEmailInputField({super.key, this.controller, this.onChanged});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.tr('auth.signup.email'),
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.email],
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: authFieldDecoration(
            context,
            hintText: context.tr('auth.signup.emailPlaceholder'),
          ),
        ),
      ],
    );
  }
}

/// Password input field widget with visibility toggle for signup
class SignupPasswordInputField extends StatefulWidget {
  const SignupPasswordInputField({
    super.key,
    this.controller,
    this.onChanged,
    this.label,
    this.hint,
    this.validator,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;

  @override
  State<SignupPasswordInputField> createState() =>
      _SignupPasswordInputFieldState();
}

class _SignupPasswordInputFieldState extends State<SignupPasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label ?? context.tr('auth.signup.password'),
          style: authFieldLabelStyle(context),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          validator: widget.validator,
          obscureText: _obscureText,
          enableSuggestions: false,
          autocorrect: false,
          autofillHints: const <String>[AutofillHints.newPassword],
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: authFieldDecoration(
            context,
            hintText: widget.hint ?? context.tr('auth.signup.passwordPlaceholder'),
            suffixIcon: IconButton(
              tooltip: context.tr(
                _obscureText ? 'auth.showPassword' : 'auth.hidePassword',
              ),
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
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

/// "Already have an account? Log in" row.
class LoginLink extends StatelessWidget {
  const LoginLink({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            context.tr('auth.signup.alreadyHaveAccount'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppButton.text(
            label: context.tr('auth.signup.logIn'),
            size: AppButtonSize.small,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
