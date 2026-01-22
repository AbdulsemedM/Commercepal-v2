import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/theme/colors.dart';

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
      title: const Text('Select Currency'),
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          currency.symbol,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      currency.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      currency.code,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            color: Colors.grey,
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveSelection,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
