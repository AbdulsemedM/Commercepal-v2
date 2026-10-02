import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

class CurrencySelectionBottomSheet extends StatefulWidget {
  const CurrencySelectionBottomSheet({super.key});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext context) => const CurrencySelectionBottomSheet(),
    );
  }

  @override
  State<CurrencySelectionBottomSheet> createState() =>
      _CurrencySelectionBottomSheetState();
}

class _CurrencySelectionBottomSheetState
    extends State<CurrencySelectionBottomSheet> {
  late String _selectedCurrencyCode;
  final Storage _storage = Storage();
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentSelection();
  }

  Future<void> _loadCurrentSelection() async {
    final currentCurrency = await _storage.getSelectedCurrency();
    setState(() {
      _selectedCurrencyCode = currentCurrency;
      _isLoading = false;
    });
  }

  Future<void> _saveSelection(String currencyCode) async {
    setState(() {
      _selectedCurrencyCode = currencyCode;
    });

    await _storage.saveSelectedCurrency(currencyCode);
    HapticFeedback.mediumImpact();

    if (!mounted) return;
    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.of(context).pop(currencyCode);
  }

  List<CurrencyInfo> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return CountryCurrencyConstants.supportedCurrencies;
    }
    return CountryCurrencyConstants.supportedCurrencies
        .where((currency) =>
            currency.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            currency.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            currency.symbol.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<CurrencyInfo> currencies = _filteredCurrencies;

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      context.tr('profile.selectCurrency'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    context.tr('profile.chooseYourCurrency'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: context.tr('profile.searchCurrencies'),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : currencies.isEmpty
                      ? AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: context.tr('profile.noCurrenciesFound'),
                          compact: true,
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: Spacing.md +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          itemCount: currencies.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: Spacing.gutter + 40 + Spacing.md,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final currency = currencies[index];
                            final isSelected =
                                _selectedCurrencyCode == currency.code;

                            return ListTile(
                              selected: isSelected,
                              leading: ExcludeSemantics(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? scheme.primaryContainer
                                        : scheme.surfaceContainerHigh,
                                    borderRadius: AppRadius.smAll,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        Spacing.xxs,
                                      ),
                                      child: Text(
                                        currency.symbol,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? scheme.onPrimaryContainer
                                              : scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                currency.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                currency.code,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: scheme.primary,
                                    )
                                  : null,
                              onTap: () => _saveSelection(currency.code),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
