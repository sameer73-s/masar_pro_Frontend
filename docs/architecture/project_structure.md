# Project Structure

The Onyx ESS application follows a modular, feature-based approach combined with Clean Architecture principles (Data, Domain, Presentation).

## Root Architecture

The `lib/` directory is structured as follows:

```
lib/
├── config/
├── core/
├── features/
├── firebase_notification/
├── injection/
├── network_service/
└── main.dart
```

### 1. `config/`
Contains global application configurations:
* `app_theme.dart` & `app_colors.dart`: Global styling, material themes, and color palettes.
* `routes.dart` & `route_names.dart`: Route definitions and navigation mappings.
* `strings.dart`: String constants used throughout the app (often mapped to localization keys).
* `shared_preference.dart` & `secure_storage_service.dart`: Wrappers around local storage mechanisms.

### 2. `core/`
Contains foundational code and utilities shared across all features:
* **`network/`**: The `ApiClient` wrapper around Dio for HTTP requests.
* **`errors/`**: Defines custom `AppFailure` classes and functional error handling (`Either<L, R>`).
* **`usecase/`**: Base classes for Clean Architecture UseCases.
* **`services/`**: Generic services like `DeviceInfoService`.

### 3. `features/`
This is the core of the application. The app is divided into distinct features (e.g., `auth`, `dashboard`, `reports`, `requests`, `attendance`). 

Each feature strictly follows Clean Architecture layers:

#### `data/`
* **`datasources/`**: Contains remote (API) and local (cache/DB) data source interfaces and implementations.
* **`models/`**: Data Transfer Objects (DTOs) that map JSON to Dart objects.
* **`repositories/`**: Implementations of the repository interfaces defined in the domain layer.

#### `domain/`
* **`entities/`**: Core business objects (pure Dart, no frameworks).
* **`repositories/`**: Abstract interfaces defining data operations.
* **`usecases/`**: Application-specific business rules. Each UseCase typically exposes a single `call()` method that returns an `Either<AppFailure, Result>`.

#### `presentation/`
* **`bloc/`**: State management classes (Events, States, Blocs).
* **`views/`**: Flutter UI Screens (`pages/`) and reusable widgets (`widgets/`) specific to the feature.

### 4. `injection/`
Contains dependency injection registration files. The main `injection_container.dart` imports parts (`part 'auth_injection.dart';`) to keep dependency registration modular and organized by feature.

### 5. `network_service/`
Contains specific widgets and services for listening to internet connectivity changes (`NetworkAwareWidget`).
