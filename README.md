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

## App Update Check (Firebase Remote Config)

The app checks for updates at startup using Firebase Remote Config. Configure these parameters in the [Firebase Console](https://console.firebase.google.com) under **Remote Config**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `latest_app_version_android` | String | Version Android users should have (e.g. `6.0.3`). Update when you publish to the Play Store. |
| `latest_app_version_ios` | String | Version iOS users should have (e.g. `6.0.3`). Update when you publish to the App Store. |
| `store_url_android` | String (optional) | Play Store URL. Fallback is used if empty. |
| `store_url_ios` | String (optional) | App Store URL from App Store Connect. Fallback is used if empty. |
| `minimum_supported_version` | String (optional) | Hard floor. If current &lt; minimum → blocking store update. Empty disables. |
| `kill_switch_patch_disabled` | Boolean | When `true`, skip Shorebird OTA patch checks/downloads. |
| `shorebird_patch_rollout_percent` | Number (0–100) | Staged beta-track rollout cohort size. |

- **Patch-only** change: optional update modal with “Later” and “Update”.
- **Minor or major** change: mandatory update modal with “Update” only.
- Android and iOS version numbers are independent so you can release on each store on different days.

### OTA (Shorebird)

Dart/logic hotfixes can be shipped without a store update via Shorebird. Store binaries must be built with `shorebird release`; subsequent fixes use `shorebird patch`. See [docs/ota-updates.md](docs/ota-updates.md) for patchable vs store-required changes, CLI commands, staged rollout, and QA checklist.

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
