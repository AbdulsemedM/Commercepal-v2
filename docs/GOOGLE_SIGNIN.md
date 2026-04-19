# Google Sign-In — CommercePal (full detail)

This document describes **every implemented aspect** of Google Sign-In in the CommercePal Flutter app: architecture, API payload, storage, UI, errors, native configuration, and how it differs from Firebase Auth.

---

## 1. Architecture overview

| Layer | Responsibility |
|--------|----------------|
| **Presentation** | Login screen dispatches `GoogleSignInRequested`; listens to `LoginBloc` states. |
| **BLoC** | `LoginBloc` loads `deviceId`, calls repository, updates `AuthService`, emits success/failure. |
| **Repository** | `LoginRepository.signInWithGoogle` orchestrates API + token persistence + Google profile fields. |
| **Data provider** | `GoogleSignInDataProvider` wraps `package:google_sign_in` and `ApiService` POST to OAuth2 endpoint. |
| **Storage** | `Storage` (Flutter Secure Storage) saves JWT-like tokens and a persistent `deviceId` UUID. |

**Important:** Session tokens are **not** obtained from Firebase Auth. The app uses **Google Sign-In** only to read the Google account on device, then exchanges user identity with **your backend** at `POST /api/v1/auth/oauth2/login`. The backend returns `LoginResponse` (`accessToken`, `refreshToken`, `tokenType`, `expiresIn`) the same shape as password login.

---

## 2. Dependencies

From `pubspec.yaml`:

- `google_sign_in: ^6.2.1` — Google account picker and account APIs.
- `dio: ^5.4.0` — HTTP client (via `ApiService` → `DioClient`).
- `flutter_secure_storage` — token and `device_id` persistence.

Firebase packages (`firebase_auth`, etc.) exist in the project but are **not** used in the Google Sign-In login path in `GoogleSignInDataProvider`.

---

## 3. `GoogleSignIn` construction

**File:** `lib/features/auth/login/data/data_provider/google_sign_in_data_provider.dart`

The provider constructs:

```dart
GoogleSignIn(
  scopes: [
    'email',
    'profile',
  ],
)
```

- **`serverClientId` is not set** in Dart. Server-side OAuth client configuration for backend verification (if any) is entirely on the API side; the mobile/web clients use platform-specific OAuth client IDs (see [§8](#8-platform-configuration-native--web)).
- Optional constructor injection: tests or overrides can pass `GoogleSignIn?` and `ApiService?`.

**Constant:** `_oauth2Endpoint = '/api/v1/auth/oauth2/login'` (relative to `Env.current.baseUrl` from `DioClient`).

---

## 4. Sign-in sequence (step by step)

1. **User action**  
   `login_screen.dart` → `SocialLoginButton` (Google) →  
   `context.read<LoginBloc>().add(GoogleSignInRequested(channel: PlatformUtils.getChannel()))`.

2. **BLoC** (`lib/features/auth/login/bloc/login_bloc.dart`)  
   - Emits `LoginLoading()`.  
   - Reads `deviceId` via `Storage.getOrCreateDeviceId()` (UUID v4, stored under key `device_id` in secure storage).  
   - Calls `_repository.signInWithGoogle(channel: event.channel ?? PlatformUtils.getChannel(), deviceId: deviceId)`.

3. **Repository** (`lib/features/auth/login/data/repository/login_repository.dart`)  
   - Calls `_googleSignInDataProvider.signInWithGoogle(...)`.  
   - After success, calls `getCurrentUser()` on the same provider for `email` / `displayName` / `photoUrl`.  
   - `saveTokens(accessToken, refreshToken, tokenType, expiresIn, userEmail: googleUser?.email)`.  
   - Returns a `Map` with `response` (`LoginResponse`), `userName`, `userEmail`, `userImageUrl`.

4. **Data provider** (`signInWithGoogle`)  
   - `await _googleSignIn.signOut()` — **intentional** so the account chooser appears each time.  
   - `final GoogleSignInAccount? googleUser = await _googleSignIn.signIn()`.  
   - If `googleUser == null` → throws `Exception('Google Sign In was cancelled')`.  
   - Maps `displayName` → `firstName` (first word) + `lastName` (rest joined by spaces). Empty name parts are omitted from JSON.  
   - POST body:
     - `provider`: `'GOOGLE'`
     - `providerUserId`: `googleUser.id` (string from Google)
     - `email`: `googleUser.email`
     - `firstName` / `lastName`: if non-empty
     - `deviceId`: only if non-null (always provided from BLoC today)
     - `channel`: `channel ?? _getDefaultChannel()` (see [§5](#5-channel-values-default-vs-login-screen))

5. **HTTP**  
   - Headers: `accept: application/json`, `Content-Type: application/json`.  
   - Base URL + path from `DioClient` (`lib/core/network/dio_client.dart`): `Env.current.baseUrl`, timeouts from env.

6. **Response parsing**  
   - Expects top-level JSON with a `data` object: `response.data!['data'] as Map<String, dynamic>`.  
   - `LoginResponse.fromJson(data)` expects: `accessToken`, `refreshToken`, `tokenType` (optional, default `Bearer`), `expiresIn`.

7. **BLoC success**  
   - `_authService.login(userName:, userEmail:, userImageUrl:)` — updates in-memory profile for UI.  
   - Emits `LoginSuccess(accessToken:, refreshToken:)`.

8. **BLoC failure**  
   - Maps exception strings to user messages (cancel, 401, network, generic). See [§7](#7-errors-and-logging).

---

## 5. Channel values (default vs login screen)

**`PlatformUtils.getChannel()`** — `lib/core/utils/platform_utils.dart`

| Platform | Value |
|----------|--------|
| Web (`kIsWeb`) | `WEB` |
| Android | `MOBILE_APP_ANDROID` |
| iOS | `MOBILE_APP_IOS` |
| Fallback | `WEB` |

**Login screen** passes `channel: PlatformUtils.getChannel()` into `GoogleSignInRequested`, so the OAuth request uses the **`MOBILE_APP_*`** strings on native.

**Internal fallback** `_getDefaultChannel()` in `GoogleSignInDataProvider` (used only when `channel` is null):

| Platform | Value |
|----------|--------|
| Web | `WEB` |
| Android | `ANDROID` |
| iOS | `IOS` |

If any code path called `signInWithGoogle` **without** a channel, the backend would see `ANDROID`/`IOS` instead of `MOBILE_APP_ANDROID`/`MOBILE_APP_IOS`. The primary login path always passes the event channel.

---

## 6. Device ID (not FCM)

**Storage key:** `_keyDeviceId` → `'device_id'` in secure storage.

**Method:** `getOrCreateDeviceId()` — if missing, generates `Uuid().v4()` and persists it.

This ID is sent as `deviceId` in the OAuth2 POST. It is **independent** of the FCM registration token. See `docs/FCM.md` for push identifiers.

---

## 7. Errors and logging

### Inside `GoogleSignInDataProvider`

| Situation | Behavior |
|-----------|----------|
| User cancels `signIn()` | Throws `Exception('Google Sign In was cancelled')`. |
| `response.data == null` | Throws `DioException` (bad response). |
| Missing `data` key in JSON | Throws `DioException` (invalid structure). |
| HTTP 401 | Logged; throws `Exception('Google authentication failed. Please try again.')`. |
| HTTP 404 | Throws `Exception('Google Sign In is not available. Please contact support.')`. |
| Other `DioException` | Logged and rethrown. |
| Any other error | Logged with `AppLogger.e` and rethrown. |

### Inside `LoginBloc._onGoogleSignInRequested`

User-facing `LoginFailure` messages:

- Contains `cancelled` / `canceled` → *"Google Sign In was cancelled"*
- Contains `401` / `Unauthorized` → *"Google authentication failed"*
- Contains `network` / `connection` → *"Network error. Please check your connection."*
- Else → *"Google Sign In failed. Please try again."*

---

## 8. Platform configuration (native + web)

### 8.1 Web

**File:** `web/index.html`

A meta tag supplies the **Web client** OAuth ID for the `google_sign_in` web implementation:

```html
<meta name="google-signin-client_id" content="842396421818-618itcu1kukf7lag8q1tvv29gb70lb6o.apps.googleusercontent.com">
```

Without this, Google Sign-In on web typically fails to initialize correctly.

### 8.2 iOS

**File:** `ios/Runner/Info.plist`

- **`GIDClientID`:** iOS OAuth client ID — `842396421818-ak3ugpi44r8c0ckorr1dvlm4a8623fh5.apps.googleusercontent.com`  
- **`CFBundleURLTypes`:** URL scheme for Google redirect:  
  `com.googleusercontent.apps.842396421818-ak3ugpi44r8c0ckorr1dvlm4a8623fh5`

**File:** `ios/Runner/AppDelegate.swift`

- Calls `FirebaseApp.configure()` before `GeneratedPluginRegistrant.register` (shared with Firebase; not specific to Google Sign-In logic, but required for Firebase-enabled builds).

### 8.3 Android

- **Root** `android/build.gradle.kts`: classpath `com.google.gms:google-services:4.4.2`.
- **App** `android/app/build.gradle.kts`: `id("com.google.gms.google-services")`.
- **`google-services.json`:** Expected under `android/app/` (Firebase/Google Cloud console). Package name in this project: `com.commercepal.commercepal`.

The Google Sign-In plugin on Android uses the OAuth client tied to your app signing certificate in Google Cloud Console (SHA-1/256 for debug/release).

### 8.4 Structure of `google-services.json` (Android)

These files are **gitignored** in this repo (see root `.gitignore`: `android/app/google-services.json`). Below is the **shape** Firebase gives you when you download the app from the Firebase console (values are placeholders — use your real file).

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

**Sign-In relevance:**

- **`oauth_client`:** Entries link OAuth client IDs to your Android package + **SHA-1** (`certificate_hash`). Google Sign-In on Android uses this binding. You often have multiple entries (e.g. debug vs release keystore) after adding each SHA-1 in Firebase.
- **`client_type`:** Commonly `1` = Android OAuth client (with `android_info`), `3` = Web client — exact numbering can vary; trust the file downloaded from Firebase.
- **`mobilesdk_app_id`:** Firebase Android app ID (`GOOGLE_APP_ID` equivalent).

### 8.5 Structure of `GoogleService-Info.plist` (iOS)

Also **gitignored** (`ios/GoogleService-Info.plist` / `**/GoogleService-Info.plist`). Typical structure (keys Firebase emits — some optional):

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

**Sign-In relevance:**

- **`CLIENT_ID` / `REVERSED_CLIENT_ID`:** Must align with **`GIDClientID`** and **`CFBundleURLSchemes`** in `Info.plist` for Google Sign-In redirects.
- **`GCM_SENDER_ID`:** FCM sender ID (same logical project as Android `project_number`).
- **`GOOGLE_APP_ID`:** Firebase iOS app identifier.

For a deeper FCM-focused note on the same files, see [FCM.md §7.3–7.4 and §8.4–8.5](./FCM.md).

---

## 9. Auth interceptor and OAuth2 requests

**File:** `lib/core/network/interceptors/auth_interceptor.dart`

Public paths explicitly skip some logic (e.g. categories, customer register). The OAuth2 login path is **not** listed as “public” in that sense, but **unauthenticated** requests work because:

- If there is no `accessToken` in storage, the interceptor does not set `Authorization`.
- So the first Google login POST proceeds without a bearer token.

After login, stored tokens are attached to subsequent API calls.

---

## 10. `AuthService` after Google login

**File:** `lib/services/auth_service.dart`

`login({userName, userEmail, userImageUrl})` sets:

- `_isLoggedIn = true`
- Profile fields for UI
- Initials from name (two words) or first letter of email

This is in-memory + tokens on disk; Google Sign-In session is separate until logout.

---

## 11. Logout and Google

**File:** `lib/features/auth/logout/data/repository/logout_repository.dart`

1. Calls API logout via `LogoutDataProvider`.
2. **Best-effort** `GoogleSignInDataProvider.signOut()` — errors swallowed.
3. `Storage.clearTokens()`.

So the user is signed out of the app and the local Google session is cleared; backend session invalidation depends on the logout API.

**Note:** `LoginRepository.signOutFromGoogle()` exists for explicit Google-only sign-out if needed elsewhere; logout flow uses `LogoutRepository`.

---

## 12. UI entry points

| Location | Behavior |
|----------|----------|
| `lib/features/auth/login/presentation/screen/login_screen.dart` | Dispatches `GoogleSignInRequested(channel: PlatformUtils.getChannel())`. |
| `lib/features/auth/login/presentation/widgets/login_widgets.dart` | `SocialLoginButton` for Google (label from localization). |
| `lib/features/auth/signup/presentation/screen/signup_screen.dart` | `SocialSignupButton` type Google with **`// TODO: Handle Google signup`** — **not implemented**. |

---

## 13. Testing hooks

`GoogleSignInDataProvider` accepts optional `GoogleSignIn` and `ApiService` for unit/widget tests.

---

## 14. Checklist (developer)

| Item | Status |
|------|--------|
| Login with Google → backend OAuth2 | Implemented |
| Token storage (same as email login) | Implemented |
| Channel `MOBILE_APP_*` from login UI | Implemented |
| Google signup from signup screen | Not implemented |
| `serverClientId` for id token to backend | Not set in app (verify backend needs) |

---

*Keep this file in sync when changing `GoogleSignIn` constructor args, OAuth path, or platform OAuth client IDs.*
