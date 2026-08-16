import '../../errors/either.dart';
import '../../errors/app_failure.dart';
import 'onyx_result_model.dart';

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

/// Parses Onyx-style `{ "Data": ..., "Result": { ErrNo, ErrMsg } }` payloads.
final class OnyxResponseParser {
  const OnyxResponseParser._();

  static Either<AppFailure, T> parse<T>(
    dynamic raw,
    T Function(Map<String, dynamic>? dataMap) mapSuccess,
  ) {
    if (raw is! Map<String, dynamic>) {
      return Either.left(
        AppFailure.unknown(message: 'Invalid response format'),
      );
    }

    final resultRaw = raw['Result'];
    if (resultRaw is! Map<String, dynamic>) {
      return Either.left(
        AppFailure.server(message: 'Missing Result in response'),
      );
    }

    OnyxResultModel result;
    try {
      result = OnyxResultModel.fromJson(resultRaw);
    } catch (_) {
      final errNo = _asInt(resultRaw['ErrNo']) ?? -1;
      final errMsg = resultRaw['ErrMsg']?.toString() ?? 'Request failed';
      if (errNo != 0) {
        return Either.left(
          AppFailure.server(message: errMsg, statusCode: errNo),
        );
      }
      return Either.left(AppFailure.unknown(message: 'Could not parse Result'));
    }

    if (result.errNo != 0 && result.errNo != 1) {
      final msg = result.errorMessage.trim().isNotEmpty
          ? result.errorMessage.trim()
          : 'Request failed';
      return Either.left(
        AppFailure.server(message: msg, statusCode: result.errNo),
      );
    }

    final dataRaw = raw['Data'];
    Map<String, dynamic>? dataMap;
    if (dataRaw == null) {
      dataMap = null;
    } else if (dataRaw is Map<String, dynamic>) {
      dataMap = dataRaw;
    } else {
      return Either.left(
        AppFailure.unknown(message: 'Invalid Data in response'),
      );
    }

    try {
      return Either.right(mapSuccess(dataMap));
    } catch (e) {
      return Either.left(AppFailure.unknown(message: 'Data processing error'));
    }
  }
}
