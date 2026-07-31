import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';

/// Soft-cream, borderless auth input decoration (login / forgot / reset).
InputDecoration authFieldDecoration(
  BuildContext context, {
  required String hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[500],
        ),
    filled: true,
    fillColor: AppDecorations.softCream,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Spacing.md,
      vertical: Spacing.md,
    ),
    suffixIcon: suffixIcon,
  );
}

TextStyle authFieldLabelStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.navy,
        fontWeight: FontWeight.w700,
      ) ??
      const TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w700,
      );
}

/// Circular back chip matching login.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(Spacing.xs),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: scheme.onSurface,
        ),
      ),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}

/// Pink → maroon gradient pill CTA used across auth screens.
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
    final bool enabled = !isLoading && onPressed != null;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? AppDecorations.primaryCtaGradient : null,
          color: enabled ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(28),
          boxShadow: enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.pink.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.md + 2),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (showArrow) ...[
                          const SizedBox(width: Spacing.xs),
                          const Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Labeled soft-cream text field for auth forms.
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.navy,
              ),
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
