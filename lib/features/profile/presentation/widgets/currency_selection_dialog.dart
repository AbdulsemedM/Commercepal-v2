import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

class CurrencySelectionDialog extends StatefulWidget {
  const CurrencySelectionDialog({super.key});

  static Future<String?> show(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => const CurrencySelectionDialog(),
    );
  }

  @override
  State<CurrencySelectionDialog> createState() => _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<CurrencySelectionDialog> {
  late String _selectedCurrencyCode;
  final Storage _storage = Storage();
  bool _isLoading = true;

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

  Future<void> _saveSelection() async {
    await _storage.saveSelectedCurrency(_selectedCurrencyCode);
    if (mounted) {
      Navigator.of(context).pop(_selectedCurrencyCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('profile.selectCurrency')),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: CountryCurrencyConstants.supportedCurrencies.length,
                itemBuilder: (BuildContext context, int index) {
                  final currency = CountryCurrencyConstants.supportedCurrencies[index];
                  final isSelected = _selectedCurrencyCode == currency.code;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Center(
                        child: Text(
                          currency.symbol,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ),
                    ),
                    title: Text(
                      currency.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      currency.code,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                        _selectedCurrencyCode = currency.code;
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
