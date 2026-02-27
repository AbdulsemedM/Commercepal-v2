import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../bloc/address_bloc.dart';
import '../../data/models/address.dart';
import '../widgets/address_card.dart';
import '../widgets/add_edit_address_dialog.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(AddressLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          LocalizationService.t(context, 'addresses.title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AddressAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizationService.t(context, 'addresses.added')),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AddressUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizationService.t(context, 'addresses.updated')),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AddressDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizationService.t(context, 'addresses.deleted')),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AddressSetDefault) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizationService.t(context, 'addresses.defaultUpdated')),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is AddressError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.lg),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AddressBloc>().add(AddressLoadRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(LocalizationService.t(context, 'addresses.retry')),
                  ),
                ],
              ),
            );
          }

          if (state is AddressLoaded) {
            final addresses = state.addresses;

            if (addresses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      LocalizationService.t(context, 'addresses.noAddressesYet'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      LocalizationService.t(context, 'addresses.addFirstHint'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AddressBloc>().add(AddressRefreshRequested());
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(Spacing.md),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return AddressCard(
                    address: addresses[index],
                    onEdit: () {
                      AddEditAddressDialog.show(
                        context,
                        address: addresses[index],
                      );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, addresses[index]);
                    },
                    onSetDefault: () {
                      if (!addresses[index].isDefault) {
                        context.read<AddressBloc>().add(
                              AddressSetDefaultRequested(
                                addressId: addresses[index].id,
                              ),
                            );
                      }
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddEditAddressDialog.show(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          LocalizationService.t(context, 'addresses.addAddress'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Address address) {
    final addressBloc = context.read<AddressBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocalizationService.t(context, 'addresses.deleteTitle')),
        content: Text(
          '${LocalizationService.t(context, 'addresses.deleteConfirm')}\n\n${address.receiverName}\n${address.street}, ${address.city}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LocalizationService.t(context, 'cart.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              addressBloc.add(
                AddressDeleteRequested(addressId: address.id),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(LocalizationService.t(context, 'addresses.delete')),
          ),
        ],
      ),
    );
  }
}
