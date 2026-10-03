import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

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

  @override
  bool operator ==(Object other) =>
      other is PriceRange && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  String label(BuildContext context, String currencySymbol) {
    String f(double v) => '$currencySymbol${MoneyFormatter.formatWhole(v)}';
    if (isAny) return context.tr('priceFilter.any');
    if (min != null && max != null) return '${f(min!)} – ${f(max!)}';
    if (max != null) {
      return context.tr('priceFilter.under', <String, Object?>{
        'amount': f(max!),
      });
    }
    return '${f(min!)}+';
  }
}

/// Rounds to 1.5 significant figures (…, 100, 150, 200, 250, … 1000, 1500).
@visibleForTesting
double nicePriceStep(double v) {
  if (v <= 0) return 0;
  final double mag =
      math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
  final double half = mag / 2;
  return math.max(half, (v / half).round() * half);
}

/// Price buckets from the quartiles of [prices], rounded to nice numbers so
/// presets make sense in any currency (ETB thousands, USD tens, …).
@visibleForTesting
List<PriceRange> pricePresetsFor(List<double> prices) {
  final List<double> sorted =
      prices.where((double p) => p > 0).toList()..sort();
  if (sorted.length < 4) return const <PriceRange>[];
  double q(double f) => sorted[((sorted.length - 1) * f).round()];
  final List<double> cuts = <double>{
    nicePriceStep(q(0.25)),
    nicePriceStep(q(0.5)),
    nicePriceStep(q(0.75)),
  }.where((double c) => c > 0).toList()
    ..sort();
  if (cuts.isEmpty) return const <PriceRange>[];
  return <PriceRange>[
    PriceRange(max: cuts.first),
    for (int i = 0; i < cuts.length - 1; i++)
      PriceRange(min: cuts[i], max: cuts[i + 1]),
    PriceRange(min: cuts.last),
  ];
}

/// Horizontal price chips derived from the current results, plus Custom.
class PriceFilterChips extends StatelessWidget {
  const PriceFilterChips({
    super.key,
    required this.currentRange,
    required this.onRangeChanged,
    required this.prices,
    this.currencySymbol = '\$',
    this.leading = const <Widget>[],
  });

  final PriceRange currentRange;
  final ValueChanged<PriceRange> onRangeChanged;

  /// Prices in the unfiltered result set, used to build presets.
  final List<double> prices;
  final String currencySymbol;

  /// Chips shown before the price chips (e.g. Sort).
  final List<Widget> leading;

  @override
  Widget build(BuildContext context) {
    final List<PriceRange> presets = pricePresetsFor(prices);
    final bool isCustom =
        !currentRange.isAny && !presets.contains(currentRange);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Row(
        children: <Widget>[
          for (final Widget w in leading)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: Spacing.xs),
              child: w,
            ),
          for (final PriceRange range in presets)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: Spacing.xs),
              child: FilterChip(
                label: Text(range.label(context, currencySymbol)),
                selected: currentRange == range,
                onSelected: (bool on) =>
                    onRangeChanged(on ? range : const PriceRange()),
              ),
            ),
          FilterChip(
            avatar: Icon(
              Icons.tune_rounded,
              size: 18,
              color: isCustom ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
            label: Text(
              isCustom
                  ? currentRange.label(context, currencySymbol)
                  : context.tr('priceFilter.custom'),
            ),
            selected: isCustom,
            onSelected: (_) => _openCustomRange(context),
          ),
        ],
      ),
    );
  }

  void _openCustomRange(BuildContext context) {
    final double top = prices.isEmpty ? 0 : prices.reduce(math.max);
    final double maxVal = math.max(nicePriceStep(top * 1.05), 50);
    double initialLow = currentRange.min ?? 0;
    double initialHigh = currentRange.max ?? maxVal;
    if (initialHigh > maxVal) initialHigh = maxVal;
    if (initialLow > initialHigh) initialLow = initialHigh;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return _CustomPriceRangeSheet(
          currencySymbol: currencySymbol,
          initialLow: initialLow,
          initialHigh: initialHigh,
          maxVal: maxVal,
          onApply: (double low, double high) {
            onRangeChanged(PriceRange(min: low, max: high));
          },
          onClear: () => onRangeChanged(const PriceRange()),
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
  late double _low = widget.initialLow;
  late double _high = widget.initialHigh;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    String f(double v) =>
        '${widget.currencySymbol}${MoneyFormatter.formatWhole(v)}';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          0,
          Spacing.lg,
          Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.tr('priceFilter.title'),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                AppButton.text(
                  label: context.tr('priceFilter.clear'),
                  onPressed: () {
                    widget.onClear();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              '${f(_low)} – ${f(_high)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            RangeSlider(
              values: RangeValues(_low, _high),
              min: 0,
              max: widget.maxVal,
              divisions: 40,
              labels: RangeLabels(f(_low), f(_high)),
              onChanged: (RangeValues values) {
                setState(() {
                  _low = values.start;
                  _high = values.end;
                });
              },
            ),
            const SizedBox(height: Spacing.md),
            AppButton.primary(
              label: context.tr('priceFilter.apply'),
              onPressed: () {
                widget.onApply(_low, _high);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
