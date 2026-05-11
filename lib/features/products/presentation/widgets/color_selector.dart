import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedColorIndex,
    required this.onColorSelected,
  });

  final List<Color> colors;
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: <Widget>[
          Text(
            '${LocalizationService.t(context, 'productDetail.color')}:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: Spacing.md),
          ...List<Widget>.generate(colors.length, (int index) {
            final bool isSelected = index == selectedColorIndex;
            final Color swatch = colors[index];
            final bool lightSwatch = swatch.computeLuminance() > 0.45;
            return GestureDetector(
              onTap: () => onColorSelected(index),
              child: Container(
                margin: const EdgeInsets.only(right: Spacing.sm),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: swatch,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? scheme.primary : scheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: lightSwatch ? Colors.black87 : Colors.white,
                        size: 18,
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}

