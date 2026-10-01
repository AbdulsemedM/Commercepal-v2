import 'package:commercepal/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/widgets/app_dialog.dart';
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
    final Color pageBg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          LocalizationService.t(context, 'addresses.title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            AppSnackbars.error(context, state.message);
          } else if (state is AddressAdded) {
            AppSnackbars.success(context, LocalizationService.t(context, 'addresses.added'));
          } else if (state is AddressUpdated) {
            AppSnackbars.success(context, LocalizationService.t(context, 'addresses.updated'));
          } else if (state is AddressDeleted) {
            AppSnackbars.success(context, LocalizationService.t(context, 'addresses.deleted'));
          } else if (state is AddressSetDefault) {
            AppSnackbars.success(context, LocalizationService.t(context, 'addresses.defaultUpdated'));
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
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      LocalizationService.t(context, 'addresses.noAddressesYet'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      LocalizationService.t(context, 'addresses.addFirstHint'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    AppDialog.show<void>(
      context,
      title: LocalizationService.t(context, 'addresses.deleteTitle'),
      message:
          '${LocalizationService.t(context, 'addresses.deleteConfirm')}\n\n${address.receiverName}\n${address.street}, ${address.city}',
      icon: const Icon(Icons.delete_outline_rounded),
      actions: <AppDialogAction>[
        AppDialogAction(label: LocalizationService.t(context, 'cart.cancel')),
        AppDialogAction(
          label: LocalizationService.t(context, 'addresses.delete'),
          isDestructive: true,
          onPressed: () {
            addressBloc.add(AddressDeleteRequested(addressId: address.id));
          },
        ),
      ],
    );
  }
}
