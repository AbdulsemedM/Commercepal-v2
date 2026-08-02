# OTA Updates (Shorebird + Firebase Remote Config)

This app uses **Shorebird** for over-the-air Dart/logic patches and **Firebase Remote Config** for store-required force updates and emergency patch kill-switch.

## What can be patched vs what needs a store release

| Change type | Delivery |
|-------------|----------|
| Dart logic, bug fixes, most UI/behavior | **Shorebird patch** (`shorebird patch`) |
| Native Android/iOS code | **Store release** (`shorebird release` → stores) |
| New/changed native plugins or dependency versions in `pubspec.yaml` | **Store release** |
| Permissions / `Info.plist` / `AndroidManifest.xml` / platform config | **Store release** |

Do **not** attempt to ship non-Dart or dependency/native changes via a patch.

## Prerequisites

1. Install [Shorebird CLI](https://docs.shorebird.dev/getting-started/) and run `shorebird login`.
2. Project must contain `shorebird.yaml` (created by `shorebird init`) with a real `app_id`.
3. Store binaries must be built with **`shorebird release`**, not plain `flutter build`. Only Shorebird releases can receive patches.

## Release workflow (store submission)

Bump `version` in `pubspec.yaml`, then:

```bash
# Pin Flutter to the version this repo targets (see .metadata / `flutter --version`).
# Do NOT omit --flutter-version: Shorebird defaults to "latest", which can mix SDKs
# with your system Flutter and break the build (SemanticsFlags / IconData errors).

# Android (App Bundle for Play Store)
shorebird release android --flutter-version=3.35.7

# iOS (requires macOS + signing)
shorebird release ios --flutter-version=3.35.7
```

Upload the produced artifacts to Play Store / App Store as usual. Record the release version (e.g. `6.0.3+153`) — patches target that exact version.

## Patch workflow (OTA hotfix)

Against an **already live** Shorebird release:

```bash
# Prefer beta track first for validation (use the same --flutter-version as the release)
shorebird patch android --release-version 6.0.4+154 --track beta --flutter-version=3.35.7
shorebird patch ios --release-version 6.0.4+154 --track beta --flutter-version=3.35.7
```

Local preview of a staging/beta patch:

```bash
shorebird preview --track beta --release-version 6.0.3+153
```

When validated, promote to production:

```bash
shorebird patches set-track --release-version 6.0.3+153 --patch-number 1 --track stable
```

Or use **Change Track → stable** in the [Shorebird console](https://console.shorebird.dev).

### Staged percentage rollout

The app assigns each device a stable cohort `1–100` and reads Remote Config `shorebird_patch_rollout_percent`:

- `0` or `100`: all devices check the **stable** track (normal production).
- `1–99`: devices with `group <= percent` check **beta**; others check **stable**.

Recommended sequence:

1. `shorebird patch … --track beta`
2. Set `shorebird_patch_rollout_percent` to `10` → `25` → `50` in Firebase Remote Config.
3. Promote the patch to `stable`.
4. Set `shorebird_patch_rollout_percent` back to `100`.

## In-app behavior

- On start and on resume (debounced ~20 minutes), the app silently checks for a patch and downloads it in the background.
- The patch is **not** applied mid-session; it applies on the next natural app restart.
- After a successful download, a dismissible snackbar is shown: *“An update will apply next time you open the app”*.
- Offline or failed downloads fail silently; the app remains usable and retries later.
- Partial download failures do not corrupt the base release; Shorebird retries on a later launch.

## Firebase Remote Config keys

| Key | Type | Purpose |
|-----|------|---------|
| `latest_app_version_android` / `latest_app_version_ios` | String | Existing store update policy (patch bump = optional; minor/major = mandatory). |
| `minimum_supported_version` | String | Hard floor. If current &lt; minimum → **blocking** store update. Empty = disabled. |
| `kill_switch_patch_disabled` | Boolean | When `true`, skip Shorebird check/download entirely. |
| `shorebird_patch_rollout_percent` | Number (0–100) | Client-side beta-track cohort size for staged rollouts. |
| `store_url_android` / `store_url_ios` | String | Store listing URLs for update modals. |

Configure these in Firebase Console → Remote Config.

## CI/CD

GitHub Actions workflows:

- `.github/workflows/shorebird-release.yml` — tag `v*` or manual dispatch → `shorebird release`
- `.github/workflows/shorebird-patch.yml` — `hotfix/**` push or manual dispatch → `shorebird patch` against a specified `release_version` (default track: `beta`)

Required secrets (never commit):

- `SHOREBIRD_TOKEN` — from Shorebird account / CI token
- Android signing: keystore + related secrets (as used by the release job)
- iOS signing: Apple certs/profiles on the macOS runner

A patch job will fail if the target release version does not exist in Shorebird — create/publish that release first.

## Manual QA checklist

- [ ] Create an internal Shorebird release (`shorebird release`) for the version under test.
- [ ] Push a visible Dart-only change via `shorebird patch … --track beta`.
- [ ] Install the **release** build (not a plain `flutter run` debug build).
- [ ] Launch once: patch downloads in background; snackbar may appear.
- [ ] Kill and relaunch: patched behavior is active.
- [ ] Repeat on both Android and iOS.
- [ ] Airplane mode on launch: app opens normally; no crash; retries when online.
- [ ] Interrupt download (toggle network mid-download): app stays usable; retry next launch.
- [ ] Set `kill_switch_patch_disabled=true`: no Shorebird network activity / no new downloads.
- [ ] Set `minimum_supported_version` above installed version: blocking store update modal.
- [ ] Promote beta → stable and confirm production track devices receive the patch.

## CLI quick reference

```bash
shorebird doctor
shorebird release android --flutter-version=3.35.7
shorebird release ios --flutter-version=3.35.7
shorebird patch android --release-version X.Y.Z+BUILD --track beta --flutter-version=3.35.7
shorebird patch ios --release-version X.Y.Z+BUILD --track beta --flutter-version=3.35.7
shorebird patches set-track --release-version X.Y.Z+BUILD --patch-number N --track stable
shorebird preview --track beta --release-version X.Y.Z+BUILD
```
