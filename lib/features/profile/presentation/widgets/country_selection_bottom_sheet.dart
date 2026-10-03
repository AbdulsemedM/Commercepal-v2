import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

class CountrySelectionBottomSheet extends StatefulWidget {
  const CountrySelectionBottomSheet({super.key});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext context) => const CountrySelectionBottomSheet(),
    );
  }

  @override
  State<CountrySelectionBottomSheet> createState() =>
      _CountrySelectionBottomSheetState();
}

class _CountrySelectionBottomSheetState
    extends State<CountrySelectionBottomSheet> {
  late String _selectedCountryCode;
  final Storage _storage = Storage();
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentSelection();
  }

  Future<void> _loadCurrentSelection() async {
    final currentCountry = await _storage.getSelectedCountry();
    setState(() {
      _selectedCountryCode = currentCountry;
      _isLoading = false;
    });
  }

  Future<void> _saveSelection(String countryCode) async {
    setState(() {
      _selectedCountryCode = countryCode;
    });

    await _storage.saveSelectedCountry(countryCode);
    HapticFeedback.mediumImpact();

    if (!mounted) return;
    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.of(context).pop(countryCode);
  }

  List<CountryInfo> get _filteredCountries {
    if (_searchQuery.isEmpty) {
      return CountryCurrencyConstants.supportedCountries;
    }
    return CountryCurrencyConstants.supportedCountries
        .where((country) =>
            country.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<CountryInfo> countries = _filteredCountries;

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
                      context.tr('profile.selectCountry'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    context.tr('profile.chooseYourLocation'),
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
                      hintText: context.tr('profile.searchCountries'),
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
                  : countries.isEmpty
                      ? AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: context.tr('profile.noCountriesFound'),
                          compact: true,
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: Spacing.md +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          itemCount: countries.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: Spacing.gutter + 40 + Spacing.md,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final country = countries[index];
                            final isSelected =
                                _selectedCountryCode == country.code;

                            return ListTile(
                              selected: isSelected,
                              leading: ExcludeSemantics(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHigh,
                                    borderRadius: AppRadius.smAll,
                                  ),
                                  child: Text(
                                    country.flagEmoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              title: Text(
                                country.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                country.code,
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
                              onTap: () => _saveSelection(country.code),
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
