import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/design_system.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: context.tr('common.goBack'),
          onPressed: () => context.pop(),
        ),
        title: Semantics(
          header: true,
          child: Text(context.tr('addresses.title')),
        ),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            AppSnackbars.error(context, state.message);
          } else if (state is AddressAdded) {
            AppSnackbars.success(context, context.tr('addresses.added'));
          } else if (state is AddressUpdated) {
            AppSnackbars.success(context, context.tr('addresses.updated'));
          } else if (state is AddressDeleted) {
            AppSnackbars.success(context, context.tr('addresses.deleted'));
          } else if (state is AddressSetDefault) {
            AppSnackbars.success(context, context.tr('addresses.defaultUpdated'));
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Spacing.gutter),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
              itemBuilder: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Spacing.xs),
                  child: ListTileShimmer(leadingSize: 40),
                ),
              ),
            );
          }

          if (state is AddressError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              isError: true,
              title: context.tr('common.somethingWentWrong'),
              subtitle: state.message,
              primaryLabel: context.tr('addresses.retry'),
              onPrimary: () {
                context.read<AddressBloc>().add(AddressLoadRequested());
              },
            );
          }

          if (state is AddressLoaded) {
            final addresses = state.addresses;

            if (addresses.isEmpty) {
              return AppEmptyState(
                icon: Icons.location_on_outlined,
                title: context.tr('addresses.noAddressesYet'),
                subtitle: context.tr('addresses.addFirstHint'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AddressBloc>().add(AddressRefreshRequested());
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                // Bottom inset keeps the last card clear of the FAB.
                padding: const EdgeInsets.fromLTRB(
                  Spacing.gutter,
                  Spacing.gutter,
                  Spacing.gutter,
                  Spacing.xxxl + Spacing.xxl,
                ),
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
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
        tooltip: context.tr('addresses.addAddress'),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('addresses.addAddress')),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Address address) {
    final addressBloc = context.read<AddressBloc>();
    AppDialog.show<void>(
      context,
      title: context.tr('addresses.deleteTitle'),
      message:
          '${context.tr('addresses.deleteConfirm')}\n\n${address.receiverName}\n${address.street}, ${address.city}',
      icon: const Icon(Icons.delete_outline_rounded),
      actions: <AppDialogAction>[
        AppDialogAction(label: context.tr('common.cancel')),
        AppDialogAction(
          label: context.tr('addresses.delete'),
          isDestructive: true,
          onPressed: () {
            addressBloc.add(AddressDeleteRequested(addressId: address.id));
          },
        ),
      ],
    );
  }
}
