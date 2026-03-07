import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/money_formatter.dart';

/// Preset or custom price range. null min/max means no bound.
class PriceRange {
  const PriceRange({this.min, this.max});

  final double? min;
  final double? max;

  bool get isAny => min == null && max == null;

  bool contains(double price) {
    if (min != null && price < min!) return false;
    if (max != null && price > max!) return false;
    return true;
  }

  String label(String currencySymbol) {
    if (isAny) return 'Any';
    if (min != null && max != null) return '$currencySymbol${MoneyFormatter.formatWhole(min!)} – $currencySymbol${MoneyFormatter.formatWhole(max!)}';
    if (max != null) return 'Under $currencySymbol${MoneyFormatter.formatWhole(max!)}';
    return '$currencySymbol${MoneyFormatter.formatWhole(min!)}+';
  }
}

/// Horizontal chips for price presets + Custom that opens a range slider.
class PriceFilterChips extends StatelessWidget {
  const PriceFilterChips({
    super.key,
    required this.currentRange,
    required this.onRangeChanged,
    this.currencySymbol = '\$',
    this.maxPriceInList = 500,
  });

  final PriceRange currentRange;
  final ValueChanged<PriceRange> onRangeChanged;
  final String currencySymbol;
  final double maxPriceInList;

  static List<PriceRange> get presets => const <PriceRange>[
        PriceRange(min: null, max: null),
        PriceRange(min: null, max: 25),
        PriceRange(min: 25, max: 50),
        PriceRange(min: 50, max: 100),
        PriceRange(min: 100, max: null),
      ];

  bool _sameRange(PriceRange a, PriceRange b) {
    return a.min == b.min && a.max == b.max;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: <Widget>[
          ...presets.map((PriceRange range) {
            final selected = _sameRange(currentRange, range);
            return Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: FilterChip(
                label: Text(
                  range.label(currencySymbol),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? Colors.white : Colors.grey[800],
                  ),
                ),
                selected: selected,
                onSelected: (_) => onRangeChanged(range),
                backgroundColor: Colors.grey[200],
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: selected ? AppColors.primary : Colors.grey[300]!,
                  width: selected ? 2 : 1,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: Spacing.md),
            child: FilterChip(
              avatar: Icon(
                Icons.tune,
                size: 18,
                color: _sameRange(currentRange, const PriceRange(min: null, max: null))
                    ? Colors.grey[600]
                    : AppColors.primary,
              ),
              label: const Text('Custom'),
              selected: !currentRange.isAny &&
                  !presets.any((p) => _sameRange(p, currentRange)),
              onSelected: (_) => _openCustomRange(context),
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              side: BorderSide(
                color: !currentRange.isAny &&
                        !presets.any((p) => _sameRange(p, currentRange))
                    ? AppColors.primary
                    : Colors.grey[300]!,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCustomRange(BuildContext context) {
    final maxVal = (maxPriceInList.clamp(50, 10000) / 50).ceil() * 50.0;
    double initialLow = currentRange.min ?? 0;
    double initialHigh = currentRange.max ?? maxVal;
    if (initialHigh > maxVal) initialHigh = maxVal;
    if (initialLow > initialHigh) initialLow = initialHigh;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _CustomPriceRangeSheet(
          currencySymbol: currencySymbol,
          initialLow: initialLow,
          initialHigh: initialHigh,
          maxVal: maxVal,
          onApply: (double low, double high) {
            onRangeChanged(PriceRange(min: low, max: high));
          },
          onClear: () {
            onRangeChanged(const PriceRange(min: null, max: null));
          },
        );
      },
    );
  }
}

class _CustomPriceRangeSheet extends StatefulWidget {
  const _CustomPriceRangeSheet({
    required this.currencySymbol,
    required this.initialLow,
    required this.initialHigh,
    required this.maxVal,
    required this.onApply,
    required this.onClear,
  });

  final String currencySymbol;
  final double initialLow;
  final double initialHigh;
  final double maxVal;
  final void Function(double low, double high) onApply;
  final VoidCallback onClear;

  @override
  State<_CustomPriceRangeSheet> createState() => _CustomPriceRangeSheetState();
}

class _CustomPriceRangeSheetState extends State<_CustomPriceRangeSheet> {
  late double _low;
  late double _high;

  @override
  void initState() {
    super.initState();
    _low = widget.initialLow;
    _high = widget.initialHigh;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        top: Spacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + Spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Price range',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  widget.onClear();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            '${widget.currencySymbol}${MoneyFormatter.formatWhole(_low)} – ${widget.currencySymbol}${MoneyFormatter.formatWhole(_high)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          RangeSlider(
            values: RangeValues(_low, _high),
            min: 0,
            max: widget.maxVal,
            divisions: (widget.maxVal / 25).clamp(4, 40).toInt(),
            activeColor: AppColors.primary,
            onChanged: (RangeValues values) {
              setState(() {
                _low = values.start;
                _high = values.end;
              });
            },
          ),
          const SizedBox(height: Spacing.md),
          FilledButton(
            onPressed: () {
              widget.onApply(_low, _high);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
