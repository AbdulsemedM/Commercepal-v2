import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../bloc/change_password_bloc.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext context) => const ChangePasswordBottomSheet(),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 0 = empty, 1 = weak, 2 = medium, 3 = strong.
  int _strengthLevel(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    if (password.length < 10) return 2;
    return 3;
  }

  String _strengthLabel(BuildContext context, int level) {
    switch (level) {
      case 1:
        return context.tr('changePassword.weak');
      case 2:
        return context.tr('changePassword.medium');
      case 3:
        return context.tr('changePassword.strong');
      default:
        return '';
    }
  }

  Color _strengthColor(BuildContext context, int level) {
    final CommerceColors c = context.commerce;
    switch (level) {
      case 1:
        return Theme.of(context).colorScheme.error;
      case 2:
        return c.warning;
      case 3:
        return c.success;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ChangePasswordBloc>().add(
            ChangePasswordSubmitted(
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
              confirmPassword: _confirmPasswordController.text,
              channel: PlatformUtils.getChannel(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordBloc(),
      child: BlocListener<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
            AppSnackbars.success(context, state.message);
          } else if (state is ChangePasswordFailure) {
            HapticFeedback.lightImpact();
            AppSnackbars.error(context, state.message);
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
              builder: (context, state) {
                final isLoading = state is ChangePasswordLoading;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.gutter,
                    0,
                    Spacing.gutter,
                    Spacing.md,
                  ),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildHeader(context),
                          const SizedBox(height: Spacing.xl),
                          _PasswordField(
                            label: context.tr('changePassword.currentPassword'),
                            hint: context.tr(
                              'changePassword.currentPasswordHint',
                            ),
                            controller: _currentPasswordController,
                            obscure: _obscureCurrentPassword,
                            enabled: !isLoading,
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            onToggle: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.tr(
                                  'changePassword.pleaseEnterCurrent',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: Spacing.md),
                          _PasswordField(
                            label: context.tr('changePassword.newPassword'),
                            hint: context.tr('changePassword.newPasswordHint'),
                            controller: _newPasswordController,
                            obscure: _obscureNewPassword,
                            enabled: !isLoading,
                            autofillHints: const <String>[
                              AutofillHints.newPassword,
                            ],
                            onToggle: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            onChanged: (value) {
                              setState(() {}); // Update strength indicator
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.tr(
                                  'changePassword.pleaseEnterNew',
                                );
                              }
                              if (value.length < 6) {
                                return context.tr(
                                  'changePassword.passwordMinLength',
                                );
                              }
                              return null;
                            },
                          ),
                          if (_newPasswordController.text.isNotEmpty) ...[
                            const SizedBox(height: Spacing.xs),
                            _buildStrengthMeter(context),
                          ],
                          const SizedBox(height: Spacing.md),
                          _PasswordField(
                            label: context.tr('changePassword.confirmPassword'),
                            hint: context.tr('changePassword.confirmHint'),
                            controller: _confirmPasswordController,
                            obscure: _obscureConfirmPassword,
                            enabled: !isLoading,
                            autofillHints: const <String>[
                              AutofillHints.newPassword,
                            ],
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (!isLoading) _submit(context);
                            },
                            onToggle: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.tr(
                                  'changePassword.pleaseConfirm',
                                );
                              }
                              if (value != _newPasswordController.text) {
                                return context.tr(
                                  'changePassword.passwordsDoNotMatch',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: Spacing.xl),
                          AppButton.primary(
                            label: context.tr('changePassword.updateButton'),
                            loading: isLoading,
                            onPressed: () => _submit(context),
                          ),
                        ],
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

  Widget _buildHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Row(
      children: <Widget>[
        ExcludeSemantics(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.lock_outline_rounded,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  context.tr('changePassword.title'),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: Spacing.xxs / 2),
              Text(
                context.tr('changePassword.subtitle'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthMeter(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int level = _strengthLevel(_newPasswordController.text);
    final Color color = _strengthColor(context, level);
    final String label = _strengthLabel(context, level);

    return Semantics(
      liveRegion: true,
      label: context.tr('changePassword.strengthValue', <String, Object?>{
        'level': label,
      }),
      excludeSemantics: true,
      child: Row(
        children: <Widget>[
          for (int i = 1; i <= 3; i++) ...<Widget>[
            Expanded(
              child: AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppMotion.fast,
                height: 4,
                decoration: BoxDecoration(
                  color: i <= level ? color : scheme.surfaceContainerHighest,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
            const SizedBox(width: Spacing.xxs),
          ],
          const SizedBox(width: Spacing.xxs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.enabled,
    required this.onToggle,
    required this.validator,
    required this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final bool enabled;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;
  final Iterable<String> autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              tooltip: context.tr(
                obscure ? 'auth.showPassword' : 'auth.hidePassword',
              ),
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
