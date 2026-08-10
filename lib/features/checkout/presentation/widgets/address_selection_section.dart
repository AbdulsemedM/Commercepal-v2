import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../../addresses/bloc/address_bloc.dart';
import '../../../addresses/data/models/address.dart';
import '../../../addresses/presentation/widgets/add_edit_address_dialog.dart';

class AddressSelectionSection extends StatefulWidget {
  const AddressSelectionSection({
    super.key,
    required this.onAddressSelected,
  });

  final void Function(Address address) onAddressSelected;

  @override
  State<AddressSelectionSection> createState() => _AddressSelectionSectionState();
}

class _AddressSelectionSectionState extends State<AddressSelectionSection> {
  int? _selectedAddressId;
  bool _hasTriggeredAutoAddressCreation = false;

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
        final ColorScheme scheme = Theme.of(context).colorScheme;
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
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    state.message,
                    style: TextStyle(color: scheme.onSurfaceVariant),
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
                    child: Text(LocalizationService.t(context, 'cart.retry')),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AddressLoaded) {
          final addresses = state.addresses;

          if (addresses.isEmpty && !_hasTriggeredAutoAddressCreation) {
            _hasTriggeredAutoAddressCreation = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              AddEditAddressDialog.show(context);
            });
          }

          // Auto-select default address if available
          if (_selectedAddressId == null && addresses.isNotEmpty) {
            final defaultAddress = addresses.firstWhere(
              (addr) => addr.isDefault,
              orElse: () => addresses.first,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedAddressId = defaultAddress.id;
                widget.onAddressSelected(defaultAddress);
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
                      LocalizationService.t(context, 'checkout.deliveryAddress'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        AddEditAddressDialog.show(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.pink,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '+ ${LocalizationService.t(context, 'checkout.addNew')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
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
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outline),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 48,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          LocalizationService.t(context, 'checkout.noAddressesFound'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          LocalizationService.t(context, 'checkout.addAddressToContinue'),
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        ElevatedButton.icon(
                          onPressed: () {
                            AddEditAddressDialog.show(context);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(LocalizationService.t(context, 'checkout.addAddress')),
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
        color: isSelected
            ? AppColors.cream
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAddressId = address.id;
            widget.onAddressSelected(address);
          });
        },
        borderRadius: BorderRadius.circular(16),
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
                      widget.onAddressSelected(address);
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
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              LocalizationService.t(
                                context,
                                'checkout.defaultLabel',
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
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
                              color: AppColors.navy,
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
                            color: Colors.grey[600],
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
                            _formatAddress(context, address),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
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

  String _formatAddress(BuildContext context, Address address) {
    final parts = <String>[];
    if (address.addressLine1 != null && address.addressLine1!.isNotEmpty) {
      parts.add(address.addressLine1!);
    }
    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      parts.add(address.addressLine2!);
    }
    if (address.street.isNotEmpty) parts.add(address.street);
    if (address.houseNumber.isNotEmpty) parts.add(address.houseNumber);
    if (address.district.isNotEmpty) parts.add(address.district);
    if (address.city.isNotEmpty) parts.add(address.city);
    if (address.state.isNotEmpty) parts.add(address.state);
    if (address.country.isNotEmpty) parts.add(address.country);
    return parts.isNotEmpty ? parts.join(', ') : LocalizationService.t(context, 'cart.noAddressDetails');
  }
}
