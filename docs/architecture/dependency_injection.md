# Dependency Injection

Dependency Injection (DI) is implemented using the **`get_it`** package, acting as a global service locator.

## Architecture & Structure

The DI setup is centralized in the `lib/injection/` folder.
* **Entry Point**: `injection_container.dart` contains the global `locator` instance (`GetIt.instance`) and the main initialization function `Future<void> init(...)`.
* **Modularity**: To prevent `injection_container.dart` from becoming a massive file, DI registrations are split into feature-specific files using Dart's `part` and `part of` directives (e.g., `part 'auth_injection.dart';`).

## Registration Strategy

Dependencies are registered based on their required lifecycles:

### 1. Lazy Singletons (`registerLazySingleton`)
Used for instances that should be created only once and shared across the entire app lifecycle.
* **Core Services**: `Dio`, `InternetConnectionChecker`, `SharedPref`, `SecureStorageService`.
* **DataSources**: Remote and Local Data Sources.
* **Repositories**: Domain Repository Implementations.
* **UseCases**: Domain UseCases (since they are typically stateless).

*Example:*
```dart
locator.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(remoteDataSource: locator(), ...),
);
```

### 2. Factories (`registerFactory`)
Used for instances that should be newly instantiated every time they are requested.
* **BLoCs / Cubits**: State management classes are strictly registered as factories. This ensures that when a user navigates to a screen, a fresh BLoC is created with a clean initial state, avoiding state leakage between screens.

*Example:*
```dart
locator.registerFactory(
  () => LoginBloc(checkLogin: locator(), ...),
);
```

## Initialization Process

1. When the app starts, `main()` calls `_initializeApp()`.
2. `_initializeApp()` fetches stored settings (like `serverUrl` and auth tokens).
3. It calls `di.init(serverUrl, token, isDemo)`.
4. The `init` function registers core external dependencies first.
5. It then sequentially calls private init methods for each feature (e.g., `_initAuth(isDemo)`, `_initHome(isDemo)`), which are defined in the separate `part` files.
6. The `isDemo` flag is elegantly used to swap out real DataSources for Mock DataSources at registration time.
