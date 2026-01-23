import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    widget.address == null ? 'Add Address' : 'Edit Address',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _receiverNameController,
                        label: 'Receiver Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter receiver name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _phoneNumberController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        hintText: _selectedCountryCode == 'ET' 
                            ? 'e.g., 0911223344 or 911223344' 
                            : null,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          // For Ethiopia, validate format
                          if (_selectedCountryCode == 'ET') {
                            final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                            final withoutLeadingZero = cleaned.startsWith('0') 
                                ? cleaned.substring(1) 
                                : cleaned;
                            if (withoutLeadingZero.length != 9) {
                              return 'Phone number must be 9 digits (e.g., 911223344)';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildCountryDropdown(),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _stateController,
                        label: 'State/Province',
                        icon: Icons.map_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter state';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _districtController,
                        label: 'District',
                        icon: Icons.place_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter district';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _streetController,
                        label: 'Street',
                        icon: Icons.streetview_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter street';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _houseNumberController,
                        label: 'House Number',
                        icon: Icons.home_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter house number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _landmarkController,
                        label: 'Landmark (Optional)',
                        icon: Icons.flag_outlined,
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _addressLine1Controller,
                        label: 'Address Line 1 (Optional)',
                        icon: Icons.description_outlined,
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildTextField(
                        controller: _addressLine2Controller,
                        label: 'Address Line 2 (Optional)',
                        icon: Icons.description_outlined,
                      ),
                      const SizedBox(height: Spacing.md),
                      CheckboxListTile(
                        value: _isDefault,
                        onChanged: (value) {
                          setState(() => _isDefault = value ?? false);
                        },
                        title: const Text('Set as default address'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: Spacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.address == null ? 'Add Address' : 'Update Address',
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCountryCode,
      decoration: InputDecoration(
        labelText: 'Country',
        prefixIcon: const Icon(Icons.flag_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      selectedItemBuilder: (BuildContext context) {
        return CountryCurrencyConstants.supportedCountries.map((country) {
          // Show only country name in selected display to avoid overflow
          return Text(
            country.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        }).toList();
      },
      items: CountryCurrencyConstants.supportedCountries.map((country) {
        return DropdownMenuItem(
          value: country.code,
          child: Text(
            '${country.flagEmoji} ${country.name}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
