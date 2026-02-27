import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../bloc/address_bloc.dart';
import '../../data/models/address.dart';
import '../../data/models/add_address_request.dart';
import '../../data/models/update_address_request.dart';

class AddEditAddressDialog extends StatefulWidget {
  const AddEditAddressDialog({
    super.key,
    this.address,
  });

  final Address? address;

  static void show(BuildContext context, {Address? address}) {
    // Capture the bloc from the parent context before showing dialog
    final bloc = context.read<AddressBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: AddEditAddressDialog(address: address),
      ),
    );
  }

  @override
  State<AddEditAddressDialog> createState() => _AddEditAddressDialogState();
}

class _AddEditAddressDialogState extends State<AddEditAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _receiverNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _streetController;
  late TextEditingController _houseNumberController;
  late TextEditingController _landmarkController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;

  String _selectedCountryCode = CountryCurrencyConstants.defaultCountryCode;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _receiverNameController = TextEditingController(
      text: widget.address?.receiverName ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: widget.address?.phoneNumber ?? '',
    );
    _stateController = TextEditingController(
      text: widget.address?.state ?? '',
    );
    _cityController = TextEditingController(
      text: widget.address?.city ?? '',
    );
    _districtController = TextEditingController(
      text: widget.address?.district ?? '',
    );
    _streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    _houseNumberController = TextEditingController(
      text: widget.address?.houseNumber ?? '',
    );
    _landmarkController = TextEditingController(
      text: widget.address?.landmark ?? '',
    );
    _addressLine1Controller = TextEditingController(
      text: widget.address?.addressLine1 ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: widget.address?.addressLine2 ?? '',
    );

    if (widget.address != null) {
      _selectedCountryCode = widget.address!.country;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _phoneNumberController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _landmarkController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phoneNumber, String countryCode) {
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // For Ethiopia (ET), format as +251XXXXXXXXX
    if (countryCode == 'ET') {
      // Remove leading 0 if present
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      // Remove +251 if already present
      if (cleaned.startsWith('+251')) {
        cleaned = cleaned.substring(4);
      } else if (cleaned.startsWith('251')) {
        cleaned = cleaned.substring(3);
      }
      // Remove any remaining + signs
      cleaned = cleaned.replaceAll('+', '');
      // Format as +251XXXXXXXXX (9 digits after +251)
      if (cleaned.length == 9) {
        return '+251$cleaned';
      }
    }
    
    // Return cleaned number for other countries or if formatting fails
    return cleaned.replaceAll('+', '');
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final rawPhoneNumber = _phoneNumberController.text.trim();
      final formattedPhoneNumber = _formatPhoneNumber(rawPhoneNumber, _selectedCountryCode);

      final requestData = {
        'receiverName': _receiverNameController.text.trim(),
        'phoneNumber': formattedPhoneNumber,
        'countryCode': _selectedCountryCode,
        'state': _stateController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _districtController.text.trim(),
        'street': _streetController.text.trim(),
        'houseNumber': _houseNumberController.text.trim(),
        'landmark': _landmarkController.text.trim().isEmpty
            ? null
            : _landmarkController.text.trim(),
        'addressLine1': _addressLine1Controller.text.trim().isEmpty
            ? null
            : _addressLine1Controller.text.trim(),
        'addressLine2': _addressLine2Controller.text.trim().isEmpty
            ? null
            : _addressLine2Controller.text.trim(),
        'latitude': widget.address?.latitude ?? '0.0',
        'longitude': widget.address?.longitude ?? '0.0',
        'addressSource': 'MANUAL',
        'isDefault': _isDefault,
      };

      if (widget.address == null) {
        // Add new address
        final request = AddAddressRequest(
          receiverName: requestData['receiverName'] as String,
          phoneNumber: requestData['phoneNumber'] as String,
          countryCode: requestData['countryCode'] as String,
          state: requestData['state'] as String,
          city: requestData['city'] as String,
          district: requestData['district'] as String,
          street: requestData['street'] as String,
          houseNumber: requestData['houseNumber'] as String,
          landmark: requestData['landmark'] as String?,
          addressLine1: requestData['addressLine1'] as String?,
          addressLine2: requestData['addressLine2'] as String?,
          latitude: requestData['latitude'] as String,
          longitude: requestData['longitude'] as String,
          addressSource: requestData['addressSource'] as String,
          isDefault: requestData['isDefault'] as bool,
        );

        context.read<AddressBloc>().add(
              AddressAddRequested(request: request),
            );
      } else {
        // Update existing address
        final request = UpdateAddressRequest(
          receiverName: requestData['receiverName'] as String,
          phoneNumber: requestData['phoneNumber'] as String,
          countryCode: requestData['countryCode'] as String,
          state: requestData['state'] as String,
          city: requestData['city'] as String,
          district: requestData['district'] as String,
          street: requestData['street'] as String,
          houseNumber: requestData['houseNumber'] as String,
          landmark: requestData['landmark'] as String?,
          addressLine1: requestData['addressLine1'] as String?,
          addressLine2: requestData['addressLine2'] as String?,
          latitude: requestData['latitude'] as String,
          longitude: requestData['longitude'] as String,
          addressSource: requestData['addressSource'] as String,
          isDefault: requestData['isDefault'] as bool,
        );

        context.read<AddressBloc>().add(
              AddressUpdateRequested(
                addressId: widget.address!.id,
                request: request,
              ),
            );
      }

      // Close dialog after a short delay to allow state updates
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: Spacing.lg,
                right: Spacing.sm,
                top: Spacing.lg,
                bottom: Spacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.85),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit
                              ? LocalizationService.t(context, 'addresses.editAddress')
                              : LocalizationService.t(context, 'addresses.addNewAddress'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEdit
                              ? LocalizationService.t(context, 'addresses.updateDeliveryDetails')
                              : LocalizationService.t(context, 'addresses.saveDeliveryLocation'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.sm),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Form(
                  key: _formKey,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(LocalizationService.t(context, 'addresses.contact')),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _receiverNameController,
                              label: LocalizationService.t(context, 'addresses.receiverName'),
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return LocalizationService.t(context, 'addresses.pleaseEnterReceiverName');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: Spacing.sm),
                            _buildTextField(
                              controller: _phoneNumberController,
                              label: LocalizationService.t(context, 'addresses.phoneNumber'),
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              hintText: _selectedCountryCode == 'ET'
                                  ? 'e.g., 0911223344'
                                  : null,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return LocalizationService.t(context, 'addresses.pleaseEnterPhone');
                                }
                                if (_selectedCountryCode == 'ET') {
                                  final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                                  final withoutLeadingZero =
                                      cleaned.startsWith('0') ? cleaned.substring(1) : cleaned;
                                  if (withoutLeadingZero.length != 9) {
                                    return LocalizationService.t(context, 'addresses.phoneMustBe9Digits');
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      _buildSectionLabel(LocalizationService.t(context, 'addresses.location')),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildCountryDropdown(),
                            const SizedBox(height: Spacing.sm),
                            _buildTextField(
                              controller: _stateController,
                              label: LocalizationService.t(context, 'addresses.stateProvince'),
                              icon: Icons.map_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return LocalizationService.t(context, 'addresses.pleaseEnterState');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: Spacing.sm),
                            _buildTextField(
                              controller: _cityController,
                              label: LocalizationService.t(context, 'addresses.city'),
                              icon: Icons.location_city_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return LocalizationService.t(context, 'addresses.pleaseEnterCity');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: Spacing.sm),
                            _buildTextField(
                              controller: _districtController,
                              label: LocalizationService.t(context, 'addresses.district'),
                              icon: Icons.place_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return LocalizationService.t(context, 'addresses.pleaseEnterDistrict');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      _buildSectionLabel(LocalizationService.t(context, 'addresses.streetBuilding')),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _streetController,
                              label: LocalizationService.t(context, 'addresses.street'),
                              icon: Icons.streetview_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return LocalizationService.t(context, 'addresses.pleaseEnterStreet');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: Spacing.sm),
                            _buildTextField(
                              controller: _houseNumberController,
                              label: LocalizationService.t(context, 'addresses.houseBuildingNumber'),
                              icon: Icons.home_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return LocalizationService.t(context, 'addresses.pleaseEnterHouseNumber');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: Spacing.sm),
                            _buildTextField(
                              controller: _landmarkController,
                              label: LocalizationService.t(context, 'addresses.landmarkOptional'),
                              icon: Icons.flag_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      _buildSectionLabel(LocalizationService.t(context, 'addresses.additionalOptional')),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _addressLine1Controller,
                              label: LocalizationService.t(context, 'addresses.addressLine1'),
                              icon: Icons.description_outlined,
                            ),
                            const SizedBox(height: Spacing.sm),
                            _buildTextField(
                              controller: _addressLine2Controller,
                              label: LocalizationService.t(context, 'addresses.addressLine2'),
                              icon: Icons.description_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      _buildDefaultSwitch(context),
                      const SizedBox(height: Spacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  isEdit
                                      ? LocalizationService.t(context, 'addresses.updateAddress')
                                      : LocalizationService.t(context, 'addresses.saveAddress'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: Spacing.xs, bottom: Spacing.sm),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDefaultSwitch(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              LocalizationService.t(context, 'addresses.setAsDefaultAddress'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: Spacing.sm),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 14),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCountryCode,
      decoration: InputDecoration(
        labelText: LocalizationService.t(context, 'profile.country'),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: Spacing.sm),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.flag_outlined,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 14),
      ),
      selectedItemBuilder: (BuildContext context) {
        return CountryCurrencyConstants.supportedCountries.map((country) {
          return Text(
            country.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          );
        }).toList();
      },
      items: CountryCurrencyConstants.supportedCountries.map((country) {
        return DropdownMenuItem(
          value: country.code,
          child: Text(
            '${country.flagEmoji}  ${country.name}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 15),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCountryCode = value);
        }
      },
    );
  }
}
