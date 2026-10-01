import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/home/bloc/home_catalog_mode_cubit.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Catalogue mode switcher (Retail ↔ Wholesale) as a segmented control.
class HomeCatalogModeToggle extends StatelessWidget {
  const HomeCatalogModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: BlocBuilder<HomeCatalogModeCubit, HomeCatalogMode>(
        builder: (context, mode) {
          final bool isWholesale = mode == HomeCatalogMode.wholesale;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _CatalogModeTrack(
                mode: mode,
                onSelect: (HomeCatalogMode next) {
                  if (next == mode) return;
                  HapticFeedback.selectionClick();
                  context.read<HomeCatalogModeCubit>().setMode(next);
                },
              ),
              const SizedBox(height: Spacing.xs),
              AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Text(
                  key: ValueKey<bool>(isWholesale),
                  context.tr(
                    isWholesale
                        ? 'home.catalog.wholesaleHint'
                        : 'home.catalog.retailHint',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CatalogModeTrack extends StatelessWidget {
  const _CatalogModeTrack({
    required this.mode,
    required this.onSelect,
  });

  final HomeCatalogMode mode;
  final ValueChanged<HomeCatalogMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final CommerceColors c = context.commerce;
    final bool isWholesale = mode == HomeCatalogMode.wholesale;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.pillAll,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double thumbWidth = constraints.maxWidth / 2;
          // Visual position flips in RTL so "Retail" stays first.
          final bool thumbAtEnd = isWholesale != rtl;
          return Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: AppMotion.medium,
                curve: AppMotion.emphasized,
                left: thumbAtEnd ? thumbWidth : 0,
                top: 0,
                bottom: 0,
                width: thumbWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: AppRadius.pillAll,
                    boxShadow: AppShadows.sm(scheme.brightness),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ModeOption(
                      selected: !isWholesale,
                      label: context.tr('home.catalog.retail'),
                      icon: Icons.storefront_rounded,
                      activeColor: scheme.primary,
                      onTap: () => onSelect(HomeCatalogMode.retail),
                    ),
                  ),
                  Expanded(
                    child: _ModeOption(
                      selected: isWholesale,
                      label: context.tr('home.catalog.wholesale'),
                      icon: Icons.inventory_2_rounded,
                      activeColor: c.deal,
                      onTap: () => onSelect(HomeCatalogMode.wholesale),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.selected,
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg = selected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: selected ? activeColor : fg),
              const SizedBox(width: 6),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: AppMotion.fast,
                  style: (theme.textTheme.labelLarge ?? const TextStyle())
                      .copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
