import 'package:flutter/material.dart';
import 'package:commercepal/core/design_system.dart';
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String formatted = _formatAddress(address);
    final bool hasActions =
        !address.isDefault || address.canEdit || address.canDelete;

    return Card(
      shape: address.isDefault
          ? RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
              side: BorderSide(color: scheme.primary, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Spacing.md,
          Spacing.md,
          Spacing.md,
          Spacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 2),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: AppSizes.iconMd,
                    color: address.isDefault
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: Spacing.xs,
                        runSpacing: Spacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            address.receiverName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          if (address.isDefault)
                            AppBadge(
                              label: context.tr('addresses.card.defaultBadge'),
                              tone: AppBadgeTone.brand,
                              icon: Icons.check_rounded,
                            ),
                        ],
                      ),
                      if (formatted.isNotEmpty) ...[
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          formatted,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (address.phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: Spacing.xxs),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: AppSizes.iconSm,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: Spacing.xxs),
                            Flexible(
                              child: Text(
                                address.phoneNumber,
                                textDirection: TextDirection.ltr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontFeatures: AppTypography.tabularFigures,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (hasActions) ...[
              const SizedBox(height: Spacing.xs),
              Divider(height: 1, color: context.commerce.border),
              Wrap(
                spacing: Spacing.xxs,
                children: [
                  if (address.canEdit)
                    _ActionButton(
                      label: context.tr('addresses.edit'),
                      icon: Icons.edit_outlined,
                      onPressed: onEdit,
                    ),
                  if (address.canDelete)
                    _ActionButton(
                      label: context.tr('addresses.delete'),
                      icon: Icons.delete_outline_rounded,
                      color: scheme.error,
                      onPressed: onDelete,
                    ),
                  if (!address.isDefault)
                    _ActionButton(
                      label: context.tr('addresses.card.setDefault'),
                      icon: Icons.star_outline_rounded,
                      onPressed: onSetDefault,
                    ),
                ],
              ),
            ],
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      ),
      icon: Icon(icon, size: AppSizes.iconSm + 2),
      label: Text(label),
    );
  }
}
