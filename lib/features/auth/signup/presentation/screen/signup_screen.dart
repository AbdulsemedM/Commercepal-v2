import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/signup/presentation/widgets/signup_widgets.dart';
import 'package:commercepal/features/auth/login/presentation/widgets/login_widgets.dart';
import 'package:commercepal/features/auth/presentation/widgets/auth_form_widgets.dart';
import '../../bloc/signup_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Country _selectedCountry = Country.parse('ET'); // Default to Ethiopia
  String _completePhoneNumber = ''; // Full phone number with country code

  String _registrationChannel() {
    if (PlatformUtils.isIOS) {
      return 'MOBILE_APP_IOS';
      // return 'WEB';
    }
    // return 'WEB';
    return 'MOBILE_APP_ANDROID';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // Split full name if needed
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // Use the complete phone number from IntlPhoneField
      final phoneNumber = _completePhoneNumber.isNotEmpty
          ? _completePhoneNumber
          : _phoneController.text.trim();

      context.read<SignupBloc>().add(
            SignupSubmitted(
              emailAddress: _emailController.text.trim(),
              phoneNumber: phoneNumber,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              firstName: firstName,
              lastName: lastName,
              country: _selectedCountry.countryCode,
              registrationChannel: _registrationChannel(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return BlocProvider(
      create: (context) => SignupBloc(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignupSuccess) {
                AppSnackbars.success(context, state.message);
                // Navigate to login after showing success message
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go(AppRoutes.login);
                    }
                  }
                });
              } else if (state is SignupFailure) {
                AppSnackbars.error(context, state.message);
              }
            },
            child: BlocBuilder<SignupBloc, SignupState>(
              builder: (context, state) {
                final isLoading = state is SignupLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: Spacing.md),
                              AuthBackButton(
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(height: Spacing.sm),
                              Semantics(
                                header: true,
                                child: Text(
                                  context.tr('auth.signup.title'),
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                context.tr('auth.signup.subtitle'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: Spacing.xl),
                              // First and last name side by side.
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: AuthTextField(
                                      controller: _firstNameController,
                                      label: context.tr('auth.signup.firstName'),
                                      hintText: context
                                          .tr('auth.signup.firstNamePlaceholder'),
                                      keyboardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.givenName,
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return context
                                              .tr('validation.firstNameRequired');
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: Spacing.sm),
                                  Expanded(
                                    child: AuthTextField(
                                      controller: _lastNameController,
                                      label: context.tr('auth.signup.lastName'),
                                      hintText: context
                                          .tr('auth.signup.lastNamePlaceholder'),
                                      keyboardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.familyName,
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return context
                                              .tr('validation.lastNameRequired');
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Spacing.md),
                              AuthTextField(
                                controller: _emailController,
                                label: context.tr('auth.signup.email'),
                                hintText:
                                    context.tr('auth.signup.emailPlaceholder'),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const <String>[
                                  AutofillHints.email,
                                ],
                                validator: AuthValidators.email(context),
                              ),
                              const SizedBox(height: Spacing.md),
                              _buildPhoneNumberField(),
                              const SizedBox(height: Spacing.md),
                              _buildCountryPickerField(),
                              const SizedBox(height: Spacing.md),
                              PasswordInputField(
                                controller: _passwordController,
                                isNewPassword: true,
                                textInputAction: TextInputAction.next,
                                label: context.tr('auth.signup.password'),
                                hintText:
                                    context.tr('auth.signup.passwordPlaceholder'),
                                validator: AuthValidators.password(context),
                              ),
                              const SizedBox(height: Spacing.md),
                              PasswordInputField(
                                controller: _confirmPasswordController,
                                isNewPassword: true,
                                label: context.tr('auth.signup.confirmPassword'),
                                hintText: context
                                    .tr('auth.signup.confirmPasswordPlaceholder'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context
                                        .tr('auth.reset.confirmPasswordRequired');
                                  }
                                  if (value != _passwordController.text) {
                                    return context
                                        .tr('auth.reset.passwordsDoNotMatch');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Spacing.lg),
                              TermsAndPolicyText(
                                onTermsTap: () {
                                  context.push(AppRoutes.termsConditions);
                                },
                                onPrivacyTap: () {
                                  context.push(AppRoutes.termsConditions);
                                },
                                onPolicyTap: () {
                                  context.push(AppRoutes.refundPolicy);
                                },
                              ),
                              const SizedBox(height: Spacing.lg),
                              AuthPrimaryButton(
                                label: context
                                    .tr('auth.signup.createAccountButton'),
                                isLoading: isLoading,
                                onPressed:
                                    isLoading ? null : () => _submit(context),
                              ),
                              if (PlatformUtils.shouldShowGoogleSignInButton) ...[
                                const SizedBox(height: Spacing.lg),
                                const _OrDivider(),
                                const SizedBox(height: Spacing.lg),
                                SocialSignupButton(
                                  type: SocialLoginType.google,
                                  onPressed: () {
                                    // TODO: Handle Google signup
                                  },
                                ),
                              ],
                              const SizedBox(height: Spacing.xl),
                              LoginLink(
                                onTap: () {
                                  context.go(AppRoutes.login);
                                },
                              ),
                              const SizedBox(height: Spacing.xl),
                            ],
                          ),
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

  Widget _buildPhoneNumberField() {
    final ThemeData theme = Theme.of(context);
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
            controller: _phoneController,
            initialCountryCode: 'ET',
            flagsButtonPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
            ),
            dropdownIconPosition: IconPosition.trailing,
            textInputAction: TextInputAction.next,
            decoration: authFieldDecoration(
              context,
              hintText: context.tr('auth.login.phonePlaceholder'),
            ),
            style: theme.textTheme.bodyLarge,
            pickerDialogStyle: PickerDialogStyle(
              backgroundColor: theme.colorScheme.surface,
              searchFieldInputDecoration: InputDecoration(
                hintText: context.tr('auth.searchCountry'),
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            onChanged: (phone) {
              setState(() {
                _completePhoneNumber = phone.completeNumber;
                // Update country picker when phone field country changes
                try {
                  _selectedCountry = Country.parse(phone.countryCode);
                } catch (e) {
                  // If country code is not valid, keep current selection
                }
              });
            },
            onCountryChanged: (country) {
              // Update country picker when phone field country changes
              setState(() {
                _selectedCountry = Country.parse(country.code);
              });
            },
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) {
                return context.tr('auth.login.phoneRequired');
              }
              if (phone.number.length < 6) {
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

  void _openCountryPicker() {
    final ThemeData theme = Theme.of(context);
    showCountryPicker(
      context: context,
      favorite: ['ET'], // Ethiopia as favorite
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
      countryListTheme: CountryListThemeData(
        flagSize: 24,
        backgroundColor: theme.colorScheme.surface,
        textStyle: theme.textTheme.bodyLarge,
        searchTextStyle: theme.textTheme.bodyLarge,
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.75,
        borderRadius: AppRadius.sheet,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        inputDecoration: InputDecoration(
          hintText: context.tr('auth.searchCountry'),
          prefixIcon: const Icon(Icons.search_rounded),
        ),
      ),
    );
  }

  Widget _buildCountryPickerField() {
    final ThemeData theme = Theme.of(context);
    final String label = context.tr('auth.signup.country');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: authFieldLabelStyle(context)),
        const SizedBox(height: Spacing.xs),
        Semantics(
          button: true,
          label: label,
          value: _selectedCountry.name,
          excludeSemantics: true,
          child: InkWell(
            onTap: _openCountryPicker,
            borderRadius: AppRadius.mdAll,
            child: InputDecorator(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.expand_more_rounded),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    _selectedCountry.flagEmoji,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      _selectedCountry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Text(
            context.tr('auth.signup.or'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Social signup button. Mirrors [SocialLoginButton] with sign-up copy.
class SocialSignupButton extends StatelessWidget {
  const SocialSignupButton({super.key, required this.type, this.onPressed});

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
          context.tr('auth.signup.socialGoogle'),
          scheme.surface,
          scheme.onSurface,
          'assets/images/Google.png',
          BorderSide(color: scheme.outline),
        ),
      SocialLoginType.facebook => (
          context.tr('auth.signup.socialFacebook'),
          const Color(0xFF1877F2),
          Colors.white,
          'assets/images/Facebook.png',
          BorderSide.none,
        ),
      SocialLoginType.apple => (
          context.tr('auth.signup.socialApple'),
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
