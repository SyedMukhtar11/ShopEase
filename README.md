# ShopEase – Flutter Internship Assignment (Sankar Group)

A functional product-catalog mobile app built with Flutter. Users sign up / log in, browse products from a live public API, search and filter, view details, and save favorites that persist across restarts.

## Features (mapped to the assignment)

| Task | Implementation |
|------|----------------|
| 1. Design & setup | Material 3 theme (light + dark), animated splash screen, login/signup, responsive grid (`maxCrossAxisExtent`) that adapts to Android screen sizes |
| 2. Core screens | Login, Signup, Dashboard, Product Listing, Product Details, Favorites, Profile |
| 3. Functionality | Named-route navigation, bottom nav, validated forms, debounced search, category filter, sorting, favorites button, add-to-cart, state via **Provider** |
| 4. API integration | [DummyJSON](https://dummyjson.com) – login, products, search, categories. Loading, error (with retry) and empty states handled |
| 5. Data management | **SharedPreferences**: session, favorites, theme, local accounts (hashed passwords) |

## Demo login

- Username: `emilys`  Password: `emilyspass` (tap **Use demo account** on the login screen)
- Or create your own account via **Sign up** (stored locally on the device).

## Run instructions

```bash
# 1. Create the platform folders (android/, ios/ ...) around this code
flutter create --project-name shopease --platforms android .

# 2. Install packages
flutter pub get

# 3. Run on a device / emulator
flutter run
```

> `flutter create .` may regenerate `lib/main.dart` and `test/widget_test.dart`. If so, restore the versions from this project.

### IMPORTANT: Internet permission for release APK

Open `android/app/src/main/AndroidManifest.xml` and add this line inside `<manifest>` (above `<application>`), otherwise the **release APK cannot reach the API**:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### Build the APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```
DRIVE LINK TO ACCESS APK https://drive.google.com/file/d/1HyhZhMWIG86P6OhqfKNGuflSchAB9nxk/view?usp=sharing
### Run tests

```bash
flutter test
```

## Architecture

```
lib/
├── main.dart              # App entry, providers, routes
├── core/                  # theme, routes, constants, validators, utils
├── models/                # Product, AppUser (JSON <-> Dart)
├── services/              # ApiService (HTTP), StorageService (SharedPreferences)
├── providers/             # Auth, Product, Favorites, Theme (ChangeNotifier)
├── screens/               # UI screens (auth/, dashboard, list, detail, favorites, profile)
└── widgets/               # Reusable widgets (ProductCard, AppTextField, state views...)
```

**Pattern:** UI (screens/widgets) → Providers (state + logic) → Services (API / storage) → Models.
Screens never talk to the network or storage directly; this keeps the UI simple and the logic testable.

### Key decisions

- **Provider** for state management: simple, official-recommended, enough for this scope.
- **Services injected into providers** (constructor injection) so they can be mocked in tests.
- **Debounced search (400 ms)** plus a request-id guard so stale responses never overwrite newer results.
- **Custom `ApiException`** converts network, timeout and server errors into friendly messages.
- **Favorites stored as full product JSON** so the Favorites tab works offline.
- **Passwords for local sign-up are SHA-256 hashed** (demo level; a real app would use a backend with salted bcrypt/argon2 and secure token storage).

## Packages

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `http` | REST API calls |
| `shared_preferences` | Local persistence |
| `crypto` | Hashing local account passwords |

## How the API integration works

`ApiService` wraps every call in one `_request` method with a 15 s timeout.

- `POST /auth/login` → returns user + access token (saved in SharedPreferences)
- `GET /products?limit=100` → catalog
- `GET /products/search?q=` → search
- `GET /products/category/{slug}` → category filter
- `GET /products/category-list` → category chips

To swap in your own backend, change `AppConstants.baseUrl` and adjust the model mapping in `models/`.

## Possible extensions

Cart & checkout, pagination, offline caching (Hive/SQLite), token refresh, push notifications, localization.
