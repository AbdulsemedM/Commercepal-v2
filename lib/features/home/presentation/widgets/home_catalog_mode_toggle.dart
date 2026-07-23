import 'package:commercepal/features/home/bloc/home_catalog_mode_cubit.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Brand-styled catalogue mode switcher (Retail ↔ Wholesale).
class HomeCatalogModeToggle extends StatelessWidget {
  const HomeCatalogModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: BlocBuilder<HomeCatalogModeCubit, HomeCatalogMode>(
        builder: (context, mode) {
          final isWholesale = mode == HomeCatalogMode.wholesale;
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
              const SizedBox(height: Spacing.sm),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: Text(
                  key: ValueKey<bool>(isWholesale),
                  LocalizationService.t(
                    context,
                    isWholesale
                        ? 'home.catalog.wholesaleHint'
                        : 'home.catalog.retailHint',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
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
    final scheme = Theme.of(context).colorScheme;
    final isWholesale = mode == HomeCatalogMode.wholesale;

    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.brightness == Brightness.dark
            ? scheme.surfaceContainerHighest
            : AppDecorations.softCream,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: AppDecorations.softCardShadow(),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbWidth = (constraints.maxWidth - 8) / 2;
          return Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: isWholesale ? thumbWidth + 4 : 0,
                top: 0,
                bottom: 0,
                width: thumbWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: isWholesale
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              Color(0xFFB45309),
                              AppColors.secondary,
                            ],
                          )
                        : AppDecorations.primaryCtaGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: (isWholesale
                                ? AppColors.secondary
                                : AppColors.primary)
                            .withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ModeOption(
                      selected: !isWholesale,
                      label: LocalizationService.t(
                        context,
                        'home.catalog.retail',
                      ),
                      icon: Icons.storefront_rounded,
                      onTap: () => onSelect(HomeCatalogMode.retail),
                    ),
                  ),
                  Expanded(
                    child: _ModeOption(
                      selected: isWholesale,
                      label: LocalizationService.t(
                        context,
                        'home.catalog.wholesale',
                      ),
                      icon: Icons.inventory_2_rounded,
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
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.white24,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedScale(
                scale: selected ? 1.0 : 0.92,
                duration: const Duration(milliseconds: 220),
                child: Icon(icon, size: 20, color: fg),
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
