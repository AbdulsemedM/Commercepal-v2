import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import '../../../addresses/bloc/address_bloc.dart';
import '../../../addresses/data/models/address.dart';
import '../../../addresses/presentation/widgets/add_edit_address_dialog.dart';

class AddressSelectionSection extends StatefulWidget {
  const AddressSelectionSection({
    super.key,
    required this.onAddressSelected,
  });

  final Function(int addressId, String phoneNumber) onAddressSelected;

  @override
  State<AddressSelectionSection> createState() => _AddressSelectionSectionState();
}

class _AddressSelectionSectionState extends State<AddressSelectionSection> {
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Load addresses when widget initializes
    context.read<AddressBloc>().add(AddressLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressAdded || state is AddressUpdated) {
          // Refresh addresses after adding/updating
          context.read<AddressBloc>().add(AddressLoadRequested());
        }
        if (state is AddressError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AddressLoading) {
          return const Padding(
            padding: EdgeInsets.all(Spacing.md),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (state is AddressError) {
          return Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.md),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AddressBloc>().add(AddressLoadRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AddressLoaded) {
          final addresses = state.addresses;

          // Auto-select default address if available
          if (_selectedAddressId == null && addresses.isNotEmpty) {
            final defaultAddress = addresses.firstWhere(
              (addr) => addr.isDefault,
              orElse: () => addresses.first,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedAddressId = defaultAddress.id;
                widget.onAddressSelected(defaultAddress.id, defaultAddress.phoneNumber);
              });
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Address',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        AddEditAddressDialog.show(context);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add New'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (addresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          'No addresses found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          'Add an address to continue',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        ElevatedButton.icon(
                          onPressed: () {
                            AddEditAddressDialog.show(context);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Address'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...addresses.map((address) => _buildAddressCard(
                      context,
                      address,
                      _selectedAddressId == address.id,
                    )),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    Address address,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAddressId = address.id;
            widget.onAddressSelected(address.id, address.phoneNumber);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              Radio<int>(
                value: address.id,
                groupValue: _selectedAddressId,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAddressId = value;
                      widget.onAddressSelected(value, address.phoneNumber);
                    });
                  }
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (address.isDefault) const SizedBox(width: Spacing.xs),
                        Expanded(
                          child: Text(
                            address.receiverName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          address.phoneNumber,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatAddress(address),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(Address address) {
    final parts = <String>[];
    
    if (address.street.isNotEmpty) {
      parts.add(address.street);
    }
    if (address.houseNumber.isNotEmpty) {
      parts.add(address.houseNumber);
    }
    if (address.district.isNotEmpty) {
      parts.add(address.district);
    }
    if (address.city.isNotEmpty) {
      parts.add(address.city);
    }
    if (address.state.isNotEmpty) {
      parts.add(address.state);
    }
    if (address.country.isNotEmpty) {
      parts.add(address.country);
    }
    
    return parts.join(', ');
  }
}
