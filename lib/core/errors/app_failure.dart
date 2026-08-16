import 'package:easy_localization/easy_localization.dart';
import 'package:masar_pro/config/strings.dart';

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
  device,
}

class AppFailure {
  final String message;
  final int statusCode;
  final AppFailureType type;

  const AppFailure({
    required this.message,
    this.statusCode = 0,
    this.type = AppFailureType.unknown,
  });

  factory AppFailure.server({
    String message = Strings.serverErrorOccurred,
    int statusCode = 500,
  }) => AppFailure(
    message: message,
    statusCode: statusCode,
    type: AppFailureType.server,
  );

  factory AppFailure.connection({
    String message =
        'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
  }) => AppFailure(message: message, type: AppFailureType.connection);

  factory AppFailure.timeout({String message = Strings.requestTimedOut}) =>
      AppFailure(message: message, type: AppFailureType.timeout);

  factory AppFailure.unauthorized({
    String message = Strings.unAuthorizedAccess,
  }) => AppFailure(
    message: message,
    statusCode: 401,
    type: AppFailureType.unauthorized,
  );

  factory AppFailure.badRequest({
    String message = Strings.invalidRequest,
    int statusCode = 400,
  }) => AppFailure(
    message: message,
    statusCode: statusCode,
    type: AppFailureType.badRequest,
  );

  factory AppFailure.cancelled({
    String message = Strings.requestWasCancelled,
  }) => AppFailure(message: message, type: AppFailureType.cancelled);

  factory AppFailure.unknown({
    String message = Strings.anUnexpectedErrorOccurred,
  }) => AppFailure(message: message, type: AppFailureType.unknown);

  factory AppFailure.device({String message = Strings.deviceErrorOccurred}) =>
      AppFailure(message: message, type: AppFailureType.device);
  factory AppFailure.cache({String message = Strings.cacheErrorOccurred}) =>
      AppFailure(message: message, type: AppFailureType.cache);

  @override
  String toString() =>
      '${Strings.failure.tr()} ($type: ${message.tr()}, ${Strings.code.tr()}: $statusCode)';
}
