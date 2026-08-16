# Error Handling

The application uses a functional programming approach to error handling to ensure errors are explicitly caught and passed through the architecture layers safely.

## Functional Error Handling (`Either`)

The core of the error handling strategy is the `Either<L, R>` class located in `lib/core/errors/either.dart`. 
* `Either` forces the developer to handle both the failure case (`L` - Left) and the success case (`R` - Right).
* By convention, the Left side is always an `AppFailure`, and the Right side is the expected success Data/Model.

## `AppFailure`

Failures are modeled using the `AppFailure` class (`lib/core/errors/app_failure.dart`). It provides specific factory constructors to represent different types of errors:

* `AppFailure.server({String message, int statusCode})`: For HTTP errors (e.g., 400, 500) where the server returned an error payload.
* `AppFailure.timeout()`: For network timeouts.
* `AppFailure.connection()`: For lack of internet connectivity (`SocketException`).
* `AppFailure.cancelled()`: For aborted requests.
* `AppFailure.unknown({String message})`: A fallback for unexpected exceptions.

## Layer-by-Layer Strategy

### 1. Data Layer (DataSources & Repositories)
* **Data Sources**: Usually throw exceptions (e.g., `ServerException` or `DioException`). Alternatively, when using `ApiClient.request`, they directly return `Either<AppFailure, dynamic>`.
* **Repositories**: The Repository implementation acts as a boundary. It catches native exceptions or maps Data Source outputs, ensuring that the return type is strictly `Future<Either<AppFailure, Entity>>`.

### 2. Domain Layer (UseCases)
UseCases simply pass the `Either<AppFailure, Entity>` from the Repository to the Presentation layer. They do not throw exceptions.

### 3. Presentation Layer (BLoC & UI)
BLoCs await the UseCase result and use the `.fold()` method on the `Either` object to emit the corresponding state:

```dart
final result = await _someUseCase(params);

result.fold(
  (failure) => emit(FailureState(failure.message)), // The Left (Error)
  (data) => emit(SuccessState(data)),             // The Right (Success)
);
```

The UI listens to the BLoC state. When it receives a `FailureState`, it extracts the `message` string and displays it to the user (e.g., via a Snackbar, Dialog, or Error Widget).
