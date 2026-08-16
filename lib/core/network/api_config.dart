/// Shared HTTP API root used by feature datasources (quality, long research, etc.).
///
/// Prefer setting [baseUrl] at app startup from flavor/config. The origin must
/// **not** end with a trailing slash — [ApiClient.buildRequestUri] joins paths.
class ApiConfig {
  ApiConfig._();

  /// Production Masar Pro backend (Render). Override via `--dart-define=API_BASE_URL=...`
  /// for local development (e.g. `http://127.0.0.1:8000`).
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://masar-pro-backend.onrender.com',
  );

  /// [baseUrl] without a trailing slash.
  static String get normalizedBaseUrl {
    var value = baseUrl.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }
}
