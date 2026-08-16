enum AppFailureType {
  server,
  connection,
  timeout,
  unauthorized,
  badRequest,
  cache,
  format,
  cancelled,
  unknown,
}

class AppFailures {
  final String message;
  final int statusCode;
  final AppFailureType type;

  const AppFailures({
    required this.message,
    this.statusCode = 0,
    this.type = AppFailureType.unknown,
  });

  factory AppFailures.server({
    String message = 'Server error occurred',
    int statusCode = 500,
  }) => AppFailures(
    message: message,
    statusCode: statusCode,
    type: AppFailureType.server,
  );

  factory AppFailures.connection({String message = 'No internet connection'}) =>
      AppFailures(message: message, type: AppFailureType.connection);

  factory AppFailures.timeout({
    String message = 'Request timed out. Please check your connection.',
  }) => AppFailures(message: message, type: AppFailureType.timeout);

  factory AppFailures.unauthorized({String message = 'Unauthorized access'}) =>
      AppFailures(
        message: message,
        statusCode: 401,
        type: AppFailureType.unauthorized,
      );

  factory AppFailures.badRequest({
    String message = 'Invalid request',
    int statusCode = 400,
  }) => AppFailures(
    message: message,
    statusCode: statusCode,
    type: AppFailureType.badRequest,
  );

  factory AppFailures.cancelled({String message = 'Request was cancelled'}) =>
      AppFailures(message: message, type: AppFailureType.cancelled);

  factory AppFailures.unknown({
    String message = 'An unexpected error occurred',
  }) => AppFailures(message: message, type: AppFailureType.unknown);

  @override
  String toString() => 'AppFailure($type: $message, code: $statusCode)';
}
