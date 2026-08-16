# Networking and API

The app uses `dio` as its primary HTTP client, structured around a centralized `ApiClient` wrapper located in `lib/core/network/api_client.dart`.

## Setup and Configuration

### Dio Instance
A static `Dio` instance is maintained within `ApiClient`. It is configured with timeouts (30 seconds) and base options.

### Base URL Handling
The application supports dynamic Base URLs, meaning the user can configure their server address at runtime.
* `SharedPrefKeys.serverBaseUrlKey` stores the root URL.
* `syncResolvedMobileBaseUrl(String resolvedRoot)` updates the Dio `baseUrl` dynamically.
* `buildRequestUri()` intelligently merges the dynamic Base URL with relative endpoints, supporting both full URLs and relative paths.

### Interceptors
Interceptors are configured in `ApiClient.init()`:
1. **Logging**: `LogInterceptor` logs requests (headers, body, method) and responses (status, data) for debugging.
2. **Error Handling & 401s**: An interceptor specifically checks for `401 Unauthorized` responses. If caught, it triggers `_handleUnauthorized()`, which clears the `SecureStorageService` (tokens and user data) and forces navigation back to the Login screen via a global `navigatorKey`.
3. **Authentication**: In `injection_container.dart`, an authorization header (`Bearer $token`) is globally injected into Dio's headers upon app initialization if a user session exists.

## Making Requests

The `ApiClient` exposes a generic `request()` method.

```dart
static Future<Either<AppFailure, dynamic>> request({
  required RequestType requestType, // get, post, put, delete, patch
  required Map<String, String> headers,
  String endPoint = '',
  dynamic body,
  Map<String, String>? queryParams,
})
```

### Request/Response Flow
1. **Execution**: It executes the Dio call wrapped in a `try-catch` block.
2. **Exception Mapping**: If a `DioException` occurs (e.g., Timeout, SocketException), it catches it and maps it to a custom `AppFailure` using `_mapDioException`.
3. **Response Validation**: If the call succeeds, `_handleResponse` evaluates the status code.
   * `200-299`: Returns `Either.right(response.data)`.
   * Otherwise: Extracts the error message from the JSON body and returns `Either.left(AppFailure.server(message: ...))`.

## Type-Safe APIs (Retrofit)
While `ApiClient` provides manual generic requests, the project also utilizes `retrofit` and `retrofit_generator` (as seen in `pubspec.yaml`), which generate type-safe Dio clients based on abstract classes decorated with HTTP annotations (e.g., `@GET`, `@POST`).
