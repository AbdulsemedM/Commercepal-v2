# commercepal

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## AppDialog usage

```dart
// Example: show a custom adaptive dialog
await AppDialog.show(
  context,
  title: context.l10n.confirmTitle, // pass localized strings
  message: context.l10n.confirmMessage,
  actions: [
    AppDialogAction(label: context.l10n.cancel, onPressed: () {}),
    AppDialogAction(label: context.l10n.delete, isDestructive: true, onPressed: () {}),
    AppDialogAction(label: context.l10n.save, isPrimary: true, onPressed: () {}),
  ],
);
```
