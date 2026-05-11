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

  // Country options (US removed; Ethiopia first/default)
  final List<Map<String, String>> _countries = const [
    {'code': 'ET', 'name': 'Ethiopia'},
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
              SnackBar(
                content: Text(LocalizationService.t(context, 'profile.profileUpdatedSuccessfully')),
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
        child: Builder(
          builder: (BuildContext context) {
            final ColorScheme scheme = Theme.of(context).colorScheme;
            return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            elevation: 0,
            leading: IconButton(
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
              onPressed: () => context.pop(),
            ),
            title: Text(
              LocalizationService.t(context, 'profile.editProfile'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
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
                        context: context,
                        label: LocalizationService.t(context, 'profile.firstName'),
                        controller: _firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocalizationService.t(context, 'profile.pleaseEnterFirstName');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      // Last Name
                      _buildTextField(
                        context: context,
                        label: LocalizationService.t(context, 'profile.lastName'),
                        controller: _lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocalizationService.t(context, 'profile.pleaseEnterLastName');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      // Country
                      _buildDropdown(
                        context: context,
                        label: LocalizationService.t(context, 'profile.country'),
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
                            return LocalizationService.t(context, 'profile.pleaseSelectCountry');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      // City
                      _buildTextField(
                        context: context,
                        label: LocalizationService.t(context, 'profile.city'),
                        controller: _cityController,
                      ),
                      const SizedBox(height: Spacing.md),
                      // State/Province
                      _buildTextField(
                        context: context,
                        label: LocalizationService.t(context, 'profile.stateProvince'),
                        controller: _stateProvinceController,
                      ),
                      const SizedBox(height: Spacing.md),
                      // Preferred Language
                      _buildDropdown(
                        context: context,
                        label: LocalizationService.t(context, 'profile.preferredLanguage'),
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
                        context: context,
                        label: LocalizationService.t(context, 'profile.preferredCurrency'),
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
                        context: context,
                        label: LocalizationService.t(context, 'profile.customerNotes'),
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
                            disabledBackgroundColor:
                                scheme.surfaceContainerHighest,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      scheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  LocalizationService.t(context, 'profile.updateProfile'),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: scheme.onPrimary,
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
        );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
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
            hintText: '${LocalizationService.t(context, 'profile.enter')} $label',
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outlineVariant),
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
    required BuildContext context,
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
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
            hintText: '${LocalizationService.t(context, 'profile.select')} $label',
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outlineVariant),
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
