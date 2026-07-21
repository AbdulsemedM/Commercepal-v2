import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/auth/signup/presentation/widgets/signup_widgets.dart';
import 'package:commercepal/features/affiliate_register/presentation/bloc/affiliate_register_cubit.dart';

class AffiliateRegisterScreen extends StatefulWidget {
  const AffiliateRegisterScreen({super.key, this.onRegistrationSuccess});

  final VoidCallback? onRegistrationSuccess;

  @override
  State<AffiliateRegisterScreen> createState() =>
      _AffiliateRegisterScreenState();
}

class _AffiliateRegisterScreenState extends State<AffiliateRegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Country _selectedCountry = Country.parse('ET');
  String _completePhoneNumber = '';
  String _selectedCommissionType = 'Percentage';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AffiliateRegisterCubit(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocListener<AffiliateRegisterCubit, AffiliateRegisterState>(
            listener: (context, state) {
              if (state is AffiliateRegisterSuccess) {
                widget.onRegistrationSuccess?.call();
                context.pop();
              } else if (state is AffiliateRegisterFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<AffiliateRegisterCubit, AffiliateRegisterState>(
              builder: (context, state) {
                final isLoading = state is AffiliateRegisterLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: Spacing.md),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(Spacing.xs),
                            decoration: BoxDecoration(
                              color: AppDecorations.softCream,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: AppColors.navy,
                            ),
                          ),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          LocalizationService.t(
                            context,
                            'affiliate.registerTitle',
                          ),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.navy,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          LocalizationService.t(
                            context,
                            'affiliate.registerSubtitle',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: Spacing.lg),
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
                        _buildPhoneNumberField(),
                        const SizedBox(height: Spacing.md),
                        _buildCountryPickerField(),
                        const SizedBox(height: Spacing.md),
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
                        _buildTextField(
                          controller: _referralCodeController,
                          label: LocalizationService.t(
                            context,
                            'affiliate.referralCode',
                          ),
                          hint: LocalizationService.t(
                            context,
                            'affiliate.referralCodeHint',
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        _buildCommissionTypeField(),
                        const SizedBox(height: Spacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: isLoading
                                  ? null
                                  : AppDecorations.primaryCtaGradient,
                              color: isLoading ? Colors.grey[300] : null,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          final phoneNumber =
                                              _completePhoneNumber.isNotEmpty
                                              ? _completePhoneNumber
                                              : _phoneController.text.trim();

                                          context
                                              .read<AffiliateRegisterCubit>()
                                              .registerAffiliate(
                                                firstName: _firstNameController
                                                    .text
                                                    .trim(),
                                                lastName: _lastNameController
                                                    .text
                                                    .trim(),
                                                email: _emailController.text
                                                    .trim(),
                                                phoneNumber: phoneNumber,
                                                countryCode:
                                                    _selectedCountry.phoneCode,
                                                country: _selectedCountry
                                                    .countryCode,
                                                password:
                                                    _passwordController.text,
                                                confirmPassword:
                                                    _confirmPasswordController
                                                        .text,
                                                commissionType:
                                                    _selectedCommissionType,
                                                referralCode:
                                                    _referralCodeController
                                                        .text
                                                        .trim()
                                                        .isEmpty
                                                    ? ''
                                                    : _referralCodeController
                                                          .text
                                                          .trim(),
                                              );
                                        }
                                      },
                                borderRadius: BorderRadius.circular(28),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Spacing.md,
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<
                                                      Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                LocalizationService.t(
                                                  context,
                                                  'affiliate.registerButton',
                                                ),
                                                style: const TextStyle(
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
                              ),
                            ),
                          ),
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
            fillColor: AppDecorations.softCream,
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
            fillColor: AppDecorations.softCream,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: (phone) {
            setState(() {
              _completePhoneNumber = phone.completeNumber;
              try {
                _selectedCountry = Country.parse(phone.countryCode);
              } catch (_) {}
            });
          },
          onCountryChanged: (country) {
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
              favorite: <String>['ET'],
              showPhoneCode: false,
              onSelect: (Country country) {
                setState(() {
                  _selectedCountry = country;
                });
              },
              countryListTheme: CountryListThemeData(
                flagSize: 25,
                backgroundColor: Colors.white,
                textStyle: Theme.of(context).textTheme.bodyLarge!,
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
                searchTextStyle: Theme.of(context).textTheme.bodyLarge!,
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
              color: AppDecorations.softCream,
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

  Widget _buildCommissionTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          LocalizationService.t(context, 'affiliate.commissionType'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        DropdownButtonFormField<String>(
          value: _selectedCommissionType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppDecorations.softCream,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
          ),
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(
              value: 'Percentage',
              child: Text(
                LocalizationService.t(context, 'affiliate.percentage'),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Fixed',
              child: Text(LocalizationService.t(context, 'affiliate.fixed')),
            ),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _selectedCommissionType = value;
              });
            }
          },
        ),
      ],
    );
  }
}
