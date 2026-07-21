import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/locale/locale_controller.dart';
import 'package:commercepal/services/localization_service.dart';

/// Language option for the picker.
class _LangOption {
  const _LangOption({required this.code, required this.label});
  final String code;
  final String label;
}

const List<_LangOption> _options = [
  _LangOption(code: 'en', label: 'English'),
  _LangOption(code: 'ar', label: 'العربية'),
  _LangOption(code: 'am', label: 'አማርኛ'),
  _LangOption(code: 'so', label: 'Afaan Soomaali'),
];

class LanguageSelectionBottomSheet {
  static Future<void> show(BuildContext context) async {
    final localeController = LocaleControllerScope.of(context);
    final currentCode = localeController.locale.languageCode;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Text(
                    LocalizationService.t(sheetContext, 'profile.language'),
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                ..._options.map((_LangOption option) {
                  final isSelected = currentCode == option.code;
                  return ListTile(
                    title: Text(option.label),
                    trailing: isSelected
                        ? Icon(Icons.check, color: AppColors.primary, size: 22)
                        : null,
                    onTap: () async {
                      await localeController.setLocale(option.code);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
