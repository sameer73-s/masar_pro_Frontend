# Technology Stack

This document outlines the key dependencies and technologies used in the Onyx ESS Flutter application, as defined in `pubspec.yaml`, and describes how they are initialized.

## Core Framework
* **Flutter SDK**: ^3.10.0

## Key Dependencies

### State Management
* **`flutter_bloc`**: Used as the primary state management solution following the BLoC (Business Logic Component) pattern.
* **`equatable`**: Used extensively with BLoC events and states to simplify value equality comparisons.

### Networking & API
* **`dio` (^5.4.0)**: A powerful HTTP client for Dart, used for making API requests.
* **`retrofit` & `retrofit_generator`**: Used for generating type-safe HTTP clients.
* **`internet_connection_checker` & `connectivity_plus`**: Used to monitor network state and connectivity.

### Dependency Injection
* **`get_it`**: A service locator used for dependency injection to decouple implementation from interfaces and manage singletons/factories.

### Routing
* **Navigator 1.0**: Standard Flutter routing is used with named routes defined in `lib/config/routes.dart`.

### Localization
* **`easy_localization`**: Used for handling multiple languages (Arabic, English, French).

### Local Storage
* **`shared_preferences`**: Used for storing simple key-value pairs (like server base URL, simple settings).
* **`flutter_secure_storage`**: Used for storing sensitive information like authentication tokens and user credentials securely.

### UI & Styling
* **`google_fonts`**: For custom typography.
* **`shimmer`**: For loading state animations.
* **`pull_to_refresh`**: For implementing pull-to-refresh functionality on lists.
* **`lottie`**: For rich vector animations.
* **`flutter_staggered_animations`**: For list/grid animations.
* **`modal_bottom_sheet`**: For advanced bottom sheets.

### Other Utilities
* **`firebase_core` & `firebase_messaging`**: For push notifications.
* **`geolocator`**: For location services (likely used in attendance/check-in features).
* **`local_auth`**: For biometric authentication (fingerprint/face id).

## Initialization Flow

The application initializes these dependencies primarily in the `main()` function inside `lib/main.dart`:

1. **Flutter Binding**: `WidgetsFlutterBinding.ensureInitialized()` is called first.
2. **Easy Localization**: `EasyLocalization.ensureInitialized()` is called.
3. **Shared Preferences**: `SharedPref.instance.initialize()` is called to load local preferences.
4. **Dependency Injection**: The `di.init(...)` method from `lib/injection/injection_container.dart` is invoked to register all `GetIt` singletons (Dio, Services, Repositories, UseCases).
5. **API Client**: `ApiClient.init(...)` sets up Dio interceptors and global 401 unauthorized handling.
6. **App Execution**: The app is run by passing `MyApp` wrapped in `EasyLocalization` to `runApp()`.
