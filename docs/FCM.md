# Firebase Cloud Messaging (FCM) — CommercePal (full detail)

This document describes **every implemented aspect** of FCM in the CommercePal Flutter app: startup order, `NotificationService` behavior, token lifecycle, platform files, dependencies, gaps (background handler, backend registration), and how FCM relates to login/device IDs.

---

## 1. Purpose

FCM is used for **push notifications** to the device. The implementation centers on:

- `package:firebase_messaging`
- `Firebase.initializeApp()` from `firebase_core`
- A singleton `NotificationService` in `lib/services/notification_service.dart`

---

## 2. Startup order (critical)

**File:** `lib/main.dart`

Execution order inside the Firebase `try` block:

1. `WidgetsFlutterBinding.ensureInitialized()` (before Firebase; also `LocalizationService.ensureInitialized()` runs earlier).
2. `await Firebase.initializeApp()` — **no** `FirebaseOptions` argument in code; relies on native config files (see [§10](#10-firebase-initialization-options-vs-native-config)).
3. `AppLogger.i('Firebase initialized successfully')`.
4. **`await NotificationService.initialize()`** — permissions, token, streams, initial message.
5. `AppUpdateRemoteConfig.initialize(...)`.
6. Crashlytics: `PlatformDispatcher.instance.onError` → `FirebaseCrashlytics.instance.recordError`.
7. `FirebasePerformance.instance.setPerformanceCollectionEnabled(true)`.

If **any** step in the outer `try` throws, the catch logs *"Failed to initialize Firebase"* and **does not** rethrow — the app still runs `runApp`, but Firebase-dependent features may be partially uninitialized.

**Dependency rule from class docstring:** call `NotificationService.initialize()` **after** `Firebase.initializeApp()`.

---

## 3. `NotificationService` class

**File:** `lib/services/notification_service.dart`

- **Singleton:** private constructor `NotificationService._()`, factory returns `_instance`.
- **`initialize()`** — `static Future<void>` — main setup entry.
- **`getToken()`** — instance method — returns `FirebaseMessaging.instance.getToken()` with try/catch (logs on failure, returns `null`).

---

## 4. What `initialize()` does (line-by-line behavior)

### 4.1 Permission

```dart
final messaging = FirebaseMessaging.instance;
final settings = await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
  provisional: false,
);
```

- **iOS:** Required for notification permission; user can deny.
- **Android:** On Android 13+, notification permission is requested through this API as well.

In **debug** (`kDebugMode`), logs `authorizationStatus` and alert/badge/sound flags via `AppLogger.i`.

### 4.2 iOS foreground presentation

```dart
if (Platform.isIOS) {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}
```

When the app is **foreground**, iOS can show notification-style alerts instead of suppressing them.

### 4.3 Initial FCM token

```dart
final token = await messaging.getToken();
```

In **debug**:

- If token non-null: `debugPrint('[FCM] Token captured: $token')` and `AppLogger.i('FCM token: $token')`.
- If null: `debugPrint('[FCM] getToken() returned null (check Firebase setup / emulator)')`.

**There is no call** in this service to your REST API to register the token for the logged-in user.

### 4.4 Token refresh listener

```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  if (kDebugMode) {
    debugPrint('[FCM] Token refreshed: $newToken');
    AppLogger.i('FCM token refreshed: $newToken');
  }
});
```

When FCM rotates the token, only **debug logging** runs. **Production:** you should persist or re-register the token with your backend here.

### 4.5 Topic subscription (commented)

```dart
// await messaging.subscribeToTopic('orders');
```

Not active.

### 4.6 Message streams

| API | Handler | Current behavior |
|-----|---------|------------------|
| `FirebaseMessaging.onMessage` | `_onMessage` | Debug: logs title + `message.data`. Comment: optional in-app banner. |
| `FirebaseMessaging.onMessageOpenedApp` | `_onMessageOpenedApp` → `_handleMessageOpened` | Debug: logs `message.data`. Comment: deep link / navigation not implemented. |
| `getInitialMessage()` | `_handleMessageOpened` if non-null | Same as above when app opened from **terminated** state via notification. |

### 4.7 Errors

Any exception in `initialize()` is caught, logged with `AppLogger.e('NotificationService.initialize failed', ...)`, and **swallowed** (no rethrow).

---

## 5. What is **not** implemented

| Feature | Notes |
|---------|--------|
| **`FirebaseMessaging.onBackgroundMessage`** | No `@pragma('vm:entry-point')` top-level handler in the repo. Background data messages / handling in Dart isolate not set up. |
| **Backend token registration** | No HTTP call to register `getToken()` with your API. |
| **Deep linking from `message.data`** | `_handleMessageOpened` only logs in debug. |
| **Foreground UI** | `_onMessage` only logs; no Snackbar/banner implementation. |

---

## 6. Dependencies (`pubspec.yaml`)

Relevant packages:

- `firebase_core: ^3.6.0`
- `firebase_messaging: ^15.1.3`

Other Firebase libraries in the same app (same initialization path): `firebase_analytics`, `firebase_crashlytics`, `firebase_performance`, `firebase_remote_config`, `firebase_auth`, `firebase_storage`, `cloud_firestore`. **FCM documentation** here only covers messaging; those packages have separate usage elsewhere.

---

## 7. Android native

### 7.1 Gradle

**`android/app/build.gradle.kts`**

- `id("com.google.gms.google-services")`
- Firebase BOM: `platform("com.google.firebase:firebase-bom:32.7.2")`
- Explicit: `implementation("com.google.firebase:firebase-messaging")`
- Also: `firebase-analytics` in dependencies block

**`android/build.gradle.kts`**

- Google Services classpath `4.4.2`

### 7.2 Manifest

**`android/app/src/main/AndroidManifest.xml`**

- Does not manually declare FCM-specific services; the Flutter Firebase plugins **merge** required components from dependencies.
- For **Android 13+** notification permission, merged manifest from `firebase-messaging` / plugins may add `POST_NOTIFICATIONS`; confirm with **Build → Analyze APK** or merged manifest output if you need proof for compliance.

### 7.3 Config file

- **`google-services.json`** at `android/app/` (from Firebase console) — required for Firebase on Android including FCM.

This file is **gitignored** in this repo. The Gradle plugin reads it at build time and injects Firebase metadata (including FCM) into the merged manifest and resources.

### 7.4 Structure of `google-services.json`

Same file as used for Google Sign-In on Android. Top-level shape:

| Key | Purpose |
|-----|---------|
| `project_info` | `project_number` (FCM **sender ID** / GCM), `project_id`, `storage_bucket`, optional `firebase_url` |
| `client` | One entry per registered app (Android package, etc.) |
| `configuration_version` | Schema version (usually `"1"`) |

Each item in `client` typically includes:

| Key | Purpose |
|-----|---------|
| `client_info.mobilesdk_app_id` | Firebase Android app ID (`1:…:android:…`) |
| `client_info.android_client_info.package_name` | Must match `applicationId` (here: `com.commercepal.commercepal`) |
| `oauth_client` | OAuth client IDs (Google Sign-In / APIs); includes SHA-1–bound Android clients |
| `api_key` | Google API key used by Firebase SDKs |
| `services` | Optional service blocks (e.g. App Invite) |

**Example (illustrative — replace with your downloaded file):**

```json
{
  "project_info": {
    "project_number": "123456789012",
    "firebase_url": "https://your-project-id-default-rtdb.firebaseio.com",
    "project_id": "your-project-id",
    "storage_bucket": "your-project-id.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abcdef0123456789abcd",
        "android_client_info": {
          "package_name": "com.commercepal.commercepal"
        }
      },
      "oauth_client": [
        {
          "client_id": "123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.commercepal.commercepal",
            "certificate_hash": "aa11bb22cc33dd44ee55ff66aa77bb88cc99dd00"
          }
        },
        {
          "client_id": "123456789012-yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

**FCM relevance:** FCM does not require extra keys in this JSON beyond what Firebase generates; the **same** `google-services.json` configures `FirebaseMessaging` once `Firebase.initializeApp()` runs (with default options from native resources).

---

## 8. iOS native

### 8.1 `Info.plist` (`ios/Runner/Info.plist`)

Relevant entries:

- **`UIBackgroundModes`:** `fetch`, **`remote-notification`** — allows background push handling at system level.
- **`FirebaseMessagingAutoInitEnabled`:** `true`
- Other Firebase toggles (Analytics, Crashlytics, Performance) — see file for full list.

### 8.2 Push entitlements (`ios/Runner/Runner.entitlements`)

```xml
<key>aps-environment</key>
<string>development</string>
```

- **Development** builds: typical for local/testing.
- **App Store / TestFlight production push:** entitlement and provisioning should use **`production`** where appropriate. Update when releasing.

### 8.3 `AppDelegate.swift`

```swift
FirebaseApp.configure()
GeneratedPluginRegistrant.register(with: self)
```

Ensures Firebase (including Messaging) is configured at launch.

### 8.4 Config file

- **`GoogleService-Info.plist`** in the Xcode project (from Firebase console).

This file is **gitignored** in this repo. `FirebaseApp.configure()` loads it at runtime.

### 8.5 Structure of `GoogleService-Info.plist`

XML plist (UTF-8). Keys you will normally see (Firebase may add or omit optional keys over time):

| Key | Typical meaning |
|-----|-----------------|
| `CLIENT_ID` | OAuth 2.0 client ID (iOS client) |
| `REVERSED_CLIENT_ID` | URL scheme for Google OAuth redirect (`com.googleusercontent.apps.…`) |
| `API_KEY` | Google API key for Firebase services |
| `GCM_SENDER_ID` | Numeric **sender ID** — same project as Android `project_number`; used by FCM/APNs pipeline |
| `PLIST_VERSION` | Usually `1` |
| `BUNDLE_ID` | Must match Xcode `PRODUCT_BUNDLE_IDENTIFIER` |
| `PROJECT_ID` | Firebase / GCP project id |
| `STORAGE_BUCKET` | Default Cloud Storage bucket |
| `GOOGLE_APP_ID` | Firebase iOS app ID (`1:…:ios:…`) |
| `DATABASE_URL` | Realtime Database URL (if enabled) |
| `IS_GCM_ENABLED` | Feature flags (legacy naming; FCM still uses this plist) |
| `IS_SIGNIN_ENABLED` | Whether Google Sign-In is enabled for the project |
| `IS_ANALYTICS_ENABLED` / `IS_ADS_ENABLED` / `IS_APPINVITE_ENABLED` | Product toggles |

**Example (illustrative — use the file from Firebase Console):**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CLIENT_ID</key>
  <string>123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com</string>
  <key>REVERSED_CLIENT_ID</key>
  <string>com.googleusercontent.apps.123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
  <key>API_KEY</key>
  <string>AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</string>
  <key>GCM_SENDER_ID</key>
  <string>123456789012</string>
  <key>PLIST_VERSION</key>
  <string>1</string>
  <key>BUNDLE_ID</key>
  <string>com.yourcompany.yourapp</string>
  <key>PROJECT_ID</key>
  <string>your-project-id</string>
  <key>STORAGE_BUCKET</key>
  <string>your-project-id.appspot.com</string>
  <key>IS_ADS_ENABLED</key>
  <false/>
  <key>IS_ANALYTICS_ENABLED</key>
  <false/>
  <key>IS_APPINVITE_ENABLED</key>
  <true/>
  <key>IS_GCM_ENABLED</key>
  <true/>
  <key>IS_SIGNIN_ENABLED</key>
  <true/>
  <key>GOOGLE_APP_ID</key>
  <string>1:123456789012:ios:abcdef0123456789abcd</string>
  <key>DATABASE_URL</key>
  <string>https://your-project-id-default-rtdb.firebaseio.com</string>
</dict>
</plist>
```

**FCM relevance:** `GCM_SENDER_ID` ties the app to the Firebase project’s FCM sender; APNs credentials are configured in Firebase Console, not inside this plist. Push capability still requires **Capabilities → Push Notifications**, **Background Modes → Remote notifications**, and valid **`aps-environment`** in entitlements (see §8.2).

For Google Sign-In field overlap (`CLIENT_ID`, `REVERSED_CLIENT_ID`), see [GOOGLE_SIGNIN.md §8.5](./GOOGLE_SIGNIN.md).

---

## 9. macOS / other platforms

`macos/Flutter/GeneratedPluginRegistrant.swift` registers `firebase_messaging` and other plugins if you build for macOS; `NotificationService` uses `dart:io` `Platform.isIOS` for iOS-only presentation options — **Android vs iOS branching**; desktop behavior follows FlutterFire defaults for that platform.

---

## 10. Firebase initialization: options vs native config

`main.dart` uses:

```dart
await Firebase.initializeApp();
```

There is **no** checked-in `lib/firebase_options.dart` in the project layout used for this doc. Typical setup:

- **Android:** `google-services.json` + Gradle plugin.
- **iOS:** `GoogleService-Info.plist` + `FirebaseApp.configure()`.

FlutterFire CLI can generate `DefaultFirebaseOptions` and `firebase_options.dart` if you migrate to explicit options; current code does not require it in Dart.

---

## 11. FCM vs app `deviceId` (Google login)

- **OAuth login** sends `deviceId` from `Storage.getOrCreateDeviceId()` — a **UUID in secure storage** — see `docs/GOOGLE_SIGNIN.md`.
- **FCM** uses **`FirebaseMessaging.getToken()`** — a **Firebase registration token**, different string and lifecycle.

They are **orthogonal**. For user-targeted push you typically:

1. Associate FCM token with the user account on your server (after login).
2. Refresh association in `onTokenRefresh`.

Neither step is implemented in app HTTP code today.

---

## 12. Debugging tips

- Use **`flutter run`** and watch for `[FCM] Token captured:` / `[FCM] getToken() returned null`.
- If token is null: wrong `google-services.json` / `GoogleService-Info.plist`, or emulator without Google Play (Android), or Firebase project mismatch.

---

## 13. Checklist (developer)

| Item | Status |
|------|--------|
| `Firebase.initializeApp` before `NotificationService.initialize` | Yes |
| Permission request | Yes |
| iOS foreground presentation | Yes |
| `getToken` + debug logging | Yes |
| `onTokenRefresh` debug logging | Yes |
| `onMessage` / opened / initial message | Logged in debug only |
| Background Dart handler | **Not registered** |
| Token sent to backend | **Not in app code** |
| iOS `aps-environment` | `development` — verify for release |

---

*Update this file when adding `onBackgroundMessage`, backend registration, or navigation from `RemoteMessage.data`.*
