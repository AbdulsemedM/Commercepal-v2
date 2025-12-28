import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/profile/bloc/profile_bloc.dart';
import 'package:commercepal/features/profile/data/models/profile_data.dart';
import 'package:commercepal/features/profile/data/models/update_profile_request.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileData? initialProfile;

  const EditProfileScreen({super.key, this.initialProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cityController;
  late TextEditingController _stateProvinceController;
  late TextEditingController _customerNotesController;
  String? _selectedCountry;
  String? _selectedLanguage;
  String? _selectedCurrency;

  // Country options
  final List<Map<String, String>> _countries = const [
    {'code': 'ET', 'name': 'Ethiopia'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'KE', 'name': 'Kenya'},
    {'code': 'NG', 'name': 'Nigeria'},
    {'code': 'ZA', 'name': 'South Africa'},
  ];

  // Language options
  final List<Map<String, String>> _languages = const [
    {'code': 'en', 'name': 'English'},
    {'code': 'am', 'name': 'Amharic'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'es', 'name': 'Spanish'},
  ];

  // Currency options
  final List<Map<String, String>> _currencies = const [
    {'code': 'ETB', 'name': 'Ethiopian Birr'},
    {'code': 'USD', 'name': 'US Dollar'},
    {'code': 'GBP', 'name': 'British Pound'},
    {'code': 'EUR', 'name': 'Euro'},
    {'code': 'KES', 'name': 'Kenyan Shilling'},
    {'code': 'NGN', 'name': 'Nigerian Naira'},
    {'code': 'ZAR', 'name': 'South African Rand'},
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _stateProvinceController = TextEditingController(
      text: profile?.stateProvince ?? '',
    );
    _customerNotesController = TextEditingController(
      text: profile?.customerNotes ?? '',
    );
    _selectedCountry = profile?.country;
    _selectedLanguage = profile?.preferredLanguage;
    _selectedCurrency = profile?.preferredCurrency;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _stateProvinceController.dispose();
    _customerNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Try to get existing ProfileBloc from context, otherwise create new one
    ProfileBloc bloc;
    try {
      bloc = context.read<ProfileBloc>();
    } catch (e) {
      bloc = ProfileBloc();
    }

    return BlocProvider.value(
      value: bloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
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
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final isLoading = state is ProfileLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // First Name
                      _buildTextField(
                        label: 'First Name',
                        controller: _firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      // Last Name
                      _buildTextField(
                        label: 'Last Name',
                        controller: _lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      // Country
                      _buildDropdown(
                        label: 'Country',
                        value: _selectedCountry,
                        items: _countries
                            .map(
                              (country) => DropdownMenuItem<String>(
                                value: country['code'],
                                child: Text(country['name']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountry = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a country';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      // City
                      _buildTextField(
                        label: 'City',
                        controller: _cityController,
                      ),
                      const SizedBox(height: Spacing.md),
                      // State/Province
                      _buildTextField(
                        label: 'State/Province',
                        controller: _stateProvinceController,
                      ),
                      const SizedBox(height: Spacing.md),
                      // Preferred Language
                      _buildDropdown(
                        label: 'Preferred Language',
                        value: _selectedLanguage,
                        items: _languages
                            .map(
                              (lang) => DropdownMenuItem<String>(
                                value: lang['code'],
                                child: Text(lang['name']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      // Preferred Currency
                      _buildDropdown(
                        label: 'Preferred Currency',
                        value: _selectedCurrency,
                        items: _currencies
                            .map(
                              (currency) => DropdownMenuItem<String>(
                                value: currency['code'],
                                child: Text(currency['name']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value;
                          });
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      // Customer Notes
                      _buildTextField(
                        label: 'Customer Notes',
                        controller: _customerNotesController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: Spacing.xl),
                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    final request = UpdateProfileRequest(
                                      firstName: _firstNameController.text
                                          .trim(),
                                      lastName: _lastNameController.text.trim(),
                                      country: _selectedCountry!,
                                      city: _cityController.text.trim().isEmpty
                                          ? null
                                          : _cityController.text.trim(),
                                      stateProvince:
                                          _stateProvinceController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _stateProvinceController.text
                                                .trim(),
                                      preferredLanguage: _selectedLanguage,
                                      preferredCurrency: _selectedCurrency,
                                      customerNotes:
                                          _customerNotesController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _customerNotesController.text
                                                .trim(),
                                    );

                                    context.read<ProfileBloc>().add(
                                      ProfileUpdateRequested(request),
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
                              : Text(
                                  'Update Profile',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
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
          validator: validator,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter $label',
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Select $label',
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
}
