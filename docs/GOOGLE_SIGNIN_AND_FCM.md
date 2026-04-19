# Google Sign-In and FCM — index

This topic is split into two detailed guides:

| Document | Contents |
|----------|----------|
| **[GOOGLE_SIGNIN.md](./GOOGLE_SIGNIN.md)** | Google Sign-In architecture, `GoogleSignInDataProvider`, API `POST /api/v1/auth/oauth2/login`, BLoC/repository/storage, channel & device ID, errors, web/iOS/Android config, **`google-services.json` / `GoogleService-Info.plist` structures** (§8.4–8.5), logout, signup TODO. |
| **[FCM.md](./FCM.md)** | `NotificationService`, startup order in `main.dart`, permissions, token + `onTokenRefresh`, message handlers, Gradle/plist/entitlements, **`google-services.json` (§7.4) and `GoogleService-Info.plist` (§8.5)** field tables + examples, gaps (background handler, backend token registration), debugging. |

---

## How they relate

- **Google Sign-In** identifies the **user** and returns **app tokens** from your API. It sends a **stable `deviceId`** (UUID in secure storage), not the FCM token.
- **FCM** identifies the **device** for push. The app obtains a **Firebase registration token** but does not currently register it with your backend in Dart.

To target pushes per user, you typically register the FCM token server-side after login and update it in `onTokenRefresh`.

---

## Quick checklist

| Topic | Where to read |
|--------|----------------|
| OAuth2 endpoint & JSON body | [GOOGLE_SIGNIN.md §4–5](./GOOGLE_SIGNIN.md) |
| Platform OAuth client IDs | [GOOGLE_SIGNIN.md §8](./GOOGLE_SIGNIN.md) |
| FCM initialize & streams | [FCM.md §2–4](./FCM.md) |
| Gaps (FCM → API, background) | [FCM.md §5](./FCM.md) |

---

*Prefer editing **GOOGLE_SIGNIN.md** or **FCM.md** for substantive changes; keep this index short.*
