import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/localization_service.dart';

class CountrySelectionDialog extends StatefulWidget {
  const CountrySelectionDialog({super.key});

  static Future<String?> show(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => const CountrySelectionDialog(),
    );
  }

  @override
  State<CountrySelectionDialog> createState() => _CountrySelectionDialogState();
}

class _CountrySelectionDialogState extends State<CountrySelectionDialog> {
  late String _selectedCountryCode;
  final Storage _storage = Storage();
  bool _isLoading = true;

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

  Future<void> _saveSelection() async {
    await _storage.saveSelectedCountry(_selectedCountryCode);
    if (mounted) {
      Navigator.of(context).pop(_selectedCountryCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('profile.selectCountry')),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: CountryCurrencyConstants.supportedCountries.length,
                itemBuilder: (BuildContext context, int index) {
                  final country = CountryCurrencyConstants.supportedCountries[index];
                  final isSelected = _selectedCountryCode == country.code;

                  return ListTile(
                    leading: Text(
                      country.flagEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: isSelected,
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    onTap: () {
                      setState(() {
                        _selectedCountryCode = country.code;
                      });
                    },
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('profile.cancel')),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveSelection,
          child: Text(context.tr('profile.confirm')),
        ),
      ],
    );
  }
}
