import 'package:flutter/material.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/locale/locale_controller.dart';
import 'package:commercepal/services/localization_service.dart';

/// Language option for the picker.
class _LangOption {
  const _LangOption({required this.code, required this.label});
  final String code;
  final String label;
}

/// Endonyms: each language is shown in its own script.
const List<_LangOption> _options = [
  _LangOption(code: 'en', label: 'English'),
  _LangOption(code: 'ar', label: 'العربية'),
  _LangOption(code: 'am', label: 'አማርኛ'),
  _LangOption(code: 'so', label: 'Af-Soomaali'),
];

class LanguageSelectionBottomSheet {
  static Future<void> show(BuildContext context) async {
    final localeController = LocaleControllerScope.of(context);
    final currentCode = localeController.locale.languageCode;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);
        final ColorScheme scheme = theme.colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.gutter,
                    0,
                    Spacing.gutter,
                    Spacing.xs,
                  ),
                  child: Semantics(
                    header: true,
                    child: Text(
                      sheetContext.tr('profile.language'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
                ..._options.map((_LangOption option) {
                  final isSelected = currentCode == option.code;
                  return ListTile(
                    selected: isSelected,
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: scheme.primary)
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
