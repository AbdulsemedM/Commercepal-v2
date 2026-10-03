import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/design_system.dart';
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
          AppSnackbars.error(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is AddressLoading) {
          return const Column(
            children: <Widget>[
              ListTileShimmer(leadingSize: 24),
              ListTileShimmer(leadingSize: 24),
            ],
          );
        }

        if (state is AddressError) {
          return AppEmptyState(
            compact: true,
            isError: true,
            icon: Icons.location_off_outlined,
            title: state.message,
            primaryLabel: context.tr('common.retry'),
            onPrimary: () =>
                context.read<AddressBloc>().add(AddressLoadRequested()),
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
              SectionHeader(
                title: context.tr('checkout.deliveryAddress'),
                actionLabel: context.tr('checkout.addNew'),
                onAction: () => AddEditAddressDialog.show(context),
              ),
              const SizedBox(height: Spacing.xs),
              if (addresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.gutter,
                  ),
                  child: Card(
                    child: AppEmptyState(
                      compact: true,
                      icon: Icons.add_location_alt_outlined,
                      title: context.tr('checkout.noAddressesFound'),
                      subtitle: context.tr('checkout.addAddressToContinue'),
                      primaryLabel: context.tr('checkout.addAddress'),
                      onPrimary: () => AddEditAddressDialog.show(context),
                    ),
                  ),
                )
              else
                RadioGroup<int>(
                  groupValue: _selectedAddressId,
                  onChanged: (int? id) {
                    if (id == null) return;
                    final Address picked =
                        addresses.firstWhere((Address a) => a.id == id);
                    setState(() {
                      _selectedAddressId = id;
                      widget.onAddressSelected(picked);
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      for (final Address address in addresses)
                        _buildAddressCard(
                          context,
                          address,
                          _selectedAddressId == address.id,
                        ),
                    ],
                  ),
                ),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle? meta = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.gutter,
        vertical: Spacing.xxs,
      ),
      child: Material(
        color: isSelected ? scheme.primaryContainer : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(
            color: isSelected ? scheme.primary : context.commerce.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedAddressId = address.id;
              widget.onAddressSelected(address);
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.xxs,
              Spacing.sm,
              Spacing.md,
              Spacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Radio<int>(value: address.id),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.sm),
                        child: Wrap(
                          spacing: Spacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                              address.receiverName,
                              style: theme.textTheme.titleSmall,
                            ),
                            if (address.isDefault)
                              AppBadge(
                                label: context.tr('checkout.defaultLabel'),
                                tone: AppBadgeTone.brand,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_formatAddress(context, address), style: meta),
                      const SizedBox(height: 2),
                      Text(address.phoneNumber, style: meta),
                    ],
                  ),
                ),
              ],
            ),
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
