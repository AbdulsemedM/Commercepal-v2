import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/auth/signup/presentation/widgets/signup_widgets.dart';
import 'package:commercepal/features/auth/login/presentation/widgets/login_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocListener<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignupSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<SignupBloc, SignupState>(
              builder: (context, state) {
                final isLoading = state is SignupLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: Spacing.md),
                        // Back button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(Spacing.xs),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: Spacing.sm),
                        // Title
                        Text(
                          LocalizationService.t(context, 'auth.signup.title'),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        // Subtitle
                        Text(
                          LocalizationService.t(
                            context,
                            'auth.signup.subtitle',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: Spacing.lg),
                        // First Name and Last Name fields in a row
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                hint: 'Enter your first name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: Spacing.md),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                hint: 'Enter your last name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.md),
                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                        // Phone Number field with country code selector
                        _buildPhoneNumberField(),
                        const SizedBox(height: Spacing.md),
                        // Country picker
                        _buildCountryPickerField(),
                        const SizedBox(height: Spacing.md),
                        // Password field
                        SignupPasswordInputField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                        // Confirm Password field
                        SignupPasswordInputField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                        // Terms and Privacy Policy text
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
                        // Create Account button with arrow icon
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      // Split full name if needed
                                      final firstName = _firstNameController
                                          .text
                                          .trim();
                                      final lastName = _lastNameController.text
                                          .trim();

                                      // Use the complete phone number from IntlPhoneField
                                      final phoneNumber =
                                          _completePhoneNumber.isNotEmpty
                                          ? _completePhoneNumber
                                          : _phoneController.text.trim();

                                      context.read<SignupBloc>().add(
                                        SignupSubmitted(
                                          emailAddress: _emailController.text
                                              .trim(),
                                          phoneNumber: phoneNumber,
                                          password: _passwordController.text,
                                          confirmPassword:
                                              _confirmPasswordController.text,
                                          firstName: firstName,
                                          lastName: lastName,
                                          country: _selectedCountry.countryCode,
                                          registrationChannel:
                                              _registrationChannel(),
                                        ),
                                      );
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.md,
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        LocalizationService.t(
                                          context,
                                          'auth.signup.createAccountButton',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(width: Spacing.xs),
                                      const Icon(
                                        Icons.arrow_forward,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        // Or separator
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                              ),
                              child: Text(
                                LocalizationService.t(
                                  context,
                                  'auth.signup.or',
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xl),
                        // Social signup buttons
                        SocialSignupButton(
                          type: SocialLoginType.google,
                          onPressed: () {
                            // TODO: Handle Google signup
                          },
                        ),
                        // const SizedBox(height: Spacing.md),
                        // SocialSignupButton(
                        //   type: SocialLoginType.facebook,
                        //   onPressed: () {
                        //     // TODO: Handle Facebook signup
                        //   },
                        // ),
                        // const SizedBox(height: Spacing.md),
                        // SocialSignupButton(
                        //   type: SocialLoginType.apple,
                        //   onPressed: () {
                        //     // TODO: Handle Apple signup
                        //   },
                        // ),
                        const SizedBox(height: Spacing.xxl),
                        // Login link
                        LoginLink(
                          onTap: () {
                            context.go(AppRoutes.login);
                          },
                        ),
                        const SizedBox(height: Spacing.xl),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Phone Number',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        IntlPhoneField(
          controller: _phoneController,
          initialCountryCode: 'ET',
          flagsButtonPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
          ),
          dropdownIconPosition: IconPosition.trailing,
          decoration: InputDecoration(
            hintText: '912345678',
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
          style: Theme.of(context).textTheme.bodyLarge,
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
              return 'Please enter your phone number';
            }
            if (phone.number.length < 6) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
          searchText: 'Search country',
          invalidNumberMessage: 'Invalid phone number',
        ),
      ],
    );
  }

  Widget _buildCountryPickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Country',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        InkWell(
          onTap: () {
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
                flagSize: 25,
                backgroundColor: Colors.white,
                textStyle: Theme.of(context).textTheme.bodyLarge,
                inputDecoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Start typing to search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                searchTextStyle: Theme.of(context).textTheme.bodyLarge,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  _selectedCountry.flagEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    _selectedCountry.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Social signup button widget (adapted from SocialLoginButton)
class SocialSignupButton extends StatelessWidget {
  const SocialSignupButton({super.key, required this.type, this.onPressed});

  final SocialLoginType type;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Map<SocialLoginType, Map<String, dynamic>> buttonConfig = {
      SocialLoginType.google: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.signup.socialGoogle'),
        'backgroundColor': Colors.white,
        'textColor': Colors.black,
        'borderColor': Colors.grey[300]!,
        'imagePath': 'assets/images/Google.png',
      },
      SocialLoginType.facebook: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.signup.socialFacebook'),
        'backgroundColor': const Color(0xFF1877F2),
        'textColor': Colors.white,
        'borderColor': const Color(0xFF1877F2),
        'imagePath': 'assets/images/Facebook.png',
      },
      SocialLoginType.apple: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.signup.socialApple'),
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
