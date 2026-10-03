import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';

/// Auth input decoration: the global input theme plus a hint and suffix.
InputDecoration authFieldDecoration(
  BuildContext context, {
  required String hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(hintText: hintText, suffixIcon: suffixIcon);
}

TextStyle authFieldLabelStyle(BuildContext context) {
  return Theme.of(context).textTheme.labelLarge ??
      const TextStyle(fontWeight: FontWeight.w600);
}

/// Back button used on auth screens (RTL-aware).
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: const BackButtonIcon(),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}

/// Primary auth CTA. Thin wrapper over [AppButton].
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.showArrow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: label,
      loading: isLoading,
      trailingIcon: showArrow ? Icons.arrow_forward_rounded : null,
      onPressed: onPressed,
    );
  }
}

/// Labelled text field for auth forms.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.maxLength,
    this.autofillHints,
    this.textInputAction,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: authFieldLabelStyle(context)),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLength: maxLength,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: authFieldDecoration(
            context,
            hintText: hintText,
            suffixIcon: suffixIcon,
          ).copyWith(counterText: ''),
        ),
      ],
    );
  }
}
