import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../data/models/address.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : Colors.grey.shade300,
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: AppDecorations.softCardShadow(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            LocalizationService.t(context, 'addresses.defaultLabel'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (address.isDefault) const SizedBox(width: Spacing.sm),
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
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    } else if (value == 'set_default') {
                      onSetDefault();
                    }
                  },
                  itemBuilder: (context) => [
                    if (!address.isDefault)
                      PopupMenuItem(
                        value: 'set_default',
                        child: Row(
                          children: [
                            const Icon(Icons.star_outline, size: 18),
                            const SizedBox(width: Spacing.sm),
                            Text(LocalizationService.t(context, 'addresses.setAsDefault')),
                          ],
                        ),
                      ),
                    if (address.canEdit)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 18),
                            const SizedBox(width: Spacing.sm),
                            Text(LocalizationService.t(context, 'addresses.edit')),
                          ],
                        ),
                      ),
                    if (address.canDelete)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            const SizedBox(width: Spacing.sm),
                            Text(LocalizationService.t(context, 'addresses.delete'), style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  address.phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    _formatAddress(address),
                    style: TextStyle(
                      fontSize: 14,
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
