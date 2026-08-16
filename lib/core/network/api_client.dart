import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../config/shared_preference.dart';
import '../../config/strings.dart';
import '../errors/either.dart';
import '../errors/app_failure.dart';
import 'api_config.dart';
import 'api_headers.dart';
import 'logger.dart';
import '../../config/constants.dart';
import '../../config/secure_storage_service.dart';
import '../../injection/injection_container.dart';
import '../../config/flavor_configuration/configuration.dart';

enum RequestType { get, post, put, patch, delete }

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      // Render free tier cold start can take ~50s; content pipeline is slower.
      connectTimeout: const Duration(milliseconds: 90000),
      sendTimeout: const Duration(milliseconds: 90000),
      receiveTimeout: const Duration(milliseconds: 120000),
      baseUrl: '',
    ),
  );

  static bool _isAbsoluteHttpUrl(String value) {
    final t = value.trim();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  /// Sets [Dio.options.baseUrl] to the API origin **without** a trailing slash.
  /// [buildRequestUri] joins paths safely regardless of leading/trailing slashes.
  ///
  /// Call after startup and whenever the user updates the server URL in settings.
  static void syncResolvedMobileBaseUrl(String resolvedRoot) {
    _dio.options.baseUrl = _stripTrailingSlashes(resolvedRoot);
  }

  static String _stripTrailingSlashes(String value) {
    var t = value.trim();
    while (t.endsWith('/')) {
      t = t.substring(0, t.length - 1);
    }
    return t;
  }

  /// Joins API origin + path without producing `//` after the host.
  ///
  /// Uses [Uri.resolveUri] so callers may pass `/api/v1/...` or `api/v1/...`.
  static Uri buildRequestUri({
    String endPoint = '',
    String? serverURL,
    String? absoluteRequestUrl,
    Map<String, String>? queryParams,
  }) {
    final abs = absoluteRequestUrl?.trim();
    if (abs != null && abs.isNotEmpty) {
      return Uri.parse(abs).replace(queryParameters: queryParams);
    }

    final ep = endPoint.trim();
    if (_isAbsoluteHttpUrl(ep)) {
      return Uri.parse(ep).replace(queryParameters: queryParams);
    }

    final fromParam = serverURL?.trim();
    final dioBase = _dio.options.baseUrl.trim();
    final mergedRoot = (fromParam != null && fromParam.isNotEmpty)
        ? fromParam
        : dioBase;
    final origin = _stripTrailingSlashes(mergedRoot);
    if (origin.isEmpty) {
      final pathOnly = ep.startsWith('/') ? ep : '/$ep';
      return Uri.parse(pathOnly).replace(queryParameters: queryParams);
    }

    // Base must end with `/` for resolveUri to append path segments correctly.
    // Path-absolute endpoints (leading `/`) replace the base path — which is
    // empty after a host-only origin — yielding a single slash join.
    final base = Uri.parse('$origin/');
    final relative = ep.startsWith('/') ? ep.substring(1) : ep;
    final resolved = base.resolveUri(Uri.parse(relative));
    return resolved.replace(queryParameters: queryParams);
  }

  static GlobalKey<NavigatorState>? navigatorKey;

  /// When set (e.g. from [main]), replaces default 401 handling (clear session + navigate).
  static Future<void> Function()? onUnauthorized;

  static void init({
    GlobalKey<NavigatorState>? navigatorKey,
    Future<void> Function()? onUnauthorized,
  }) {
    ApiClient.navigatorKey = navigatorKey;
    ApiClient.onUnauthorized = onUnauthorized;
    
    // Prefer ApiConfig (Masar Pro backend) over flavor placeholders like
    // https://dev.api.example.com which always fail DNS and look like "no internet".
    // Origin is stored WITHOUT a trailing slash; [buildRequestUri] joins safely.
    final apiRoot = ApiConfig.normalizedBaseUrl;
    if (apiRoot.isNotEmpty) {
      _dio.options.baseUrl = apiRoot;
    } else {
      _dio.options.baseUrl = _stripTrailingSlashes(
        locator<Configuration>().baseUrl,
      );
    }
    _dio.options.connectTimeout = const Duration(milliseconds: 90000);
    _dio.options.sendTimeout = const Duration(milliseconds: 90000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 120000);
    log('ApiClient baseUrl=${_dio.options.baseUrl}');

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }
          handler.next(error);
        },
        onRequest: (options, handler) {
          log(
            'API Request: [${options.method}] ${options.uri}\n'
            'Headers: ${_headersForLog(options.headers)}\n'
            'Body: ${options.data}',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            'API Response: [${response.statusCode}] ${response.requestOptions.uri}\nData: ${response.data}',
          );
          handler.next(response);
        },
      ),
    );
  }

  /// Inserts at the front of the Dio interceptor chain.
  static void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.insert(0, interceptor);
  }

  static Future<void> _handleUnauthorized() async {
    try {
      final handler = onUnauthorized;
      if (handler != null) {
        await handler();
        return;
      }
      final storage = SecureStorageService();
      await storage.deleteToken();
      await storage.deleteUser();
      navigatorKey?.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (_) => false,
      );
    } catch (e) {
      AppLogger.error('Error during unauthorized handling: $e');
    }
  }

  ///  if [endPoint] is starts with http:// or https://, it will be used as full URL.
  /// Otherwise, it will merge [serverURL] / Dio base with [endPoint].
  ///
  /// When [headers] omit `Authorization`, injects Bearer auth via
  /// [ApiHeaders.authenticatedAsync] (Masar JWT or Firebase ID token).
  static Future<Either<AppFailure, dynamic>> request({
    required RequestType requestType,
    required Map<String, String> headers,
    String endPoint = '',
    String? serverURL,
    dynamic body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = buildRequestUri(
        endPoint: endPoint,
        serverURL: serverURL,
        queryParams: queryParams,
      );
      final resolvedHeaders = await _resolveAuthHeaders(headers, body: body);
      final options = Options(headers: resolvedHeaders);
      final encodedBody = body is FormData ? body : jsonEncode(body);

      final response = await _executeRequest(
        requestType: requestType,
        uri: uri,
        options: options,
        body: encodedBody,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return Either.left(_mapDioException(e));
    } on TimeoutException {
      return Either.left(AppFailure.timeout(message: Strings.serverWakingUp));
    } on SocketException catch (e) {
      return Either.left(_mapSocketException(e));
    } on FormatException {
      return Either.left(AppFailure.unknown(message: 'Data processing error'));
    } catch (_) {
      return Either.left(AppFailure.unknown());
    }
  }

  static Map<String, dynamic> _headersForLog(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    final auth = copy['Authorization']?.toString() ?? copy['authorization']?.toString();
    if (auth != null && auth.isNotEmpty) {
      // Keep enough of the token to confirm injection (Bearer eyJ...).
      final preview = auth.length <= 24 ? auth : '${auth.substring(0, 20)}...';
      copy['Authorization'] = preview;
      copy.remove('authorization');
    }
    return copy;
  }

  /// Ensures every API call carries Bearer auth unless the caller already set it.
  /// Skips forcing `Content-Type: application/json` for [FormData] so Dio can
  /// set the multipart boundary.
  static Future<Map<String, String>> _resolveAuthHeaders(
    Map<String, String> headers, {
    dynamic body,
  }) async {
    final resolved = Map<String, String>.from(headers);
    final existingAuth = resolved['Authorization']?.trim() ?? '';
    final needsAuth = existingAuth.isEmpty;

    if (!needsAuth) return resolved;

    final authHeaders = await ApiHeaders.authenticatedAsync();
    for (final entry in authHeaders.entries) {
      if (body is FormData && entry.key.toLowerCase() == 'content-type') {
        continue;
      }
      resolved.putIfAbsent(entry.key, () => entry.value);
    }
    final auth = authHeaders['Authorization'];
    if (auth != null && auth.isNotEmpty) {
      resolved['Authorization'] = auth;
    }
    return resolved;
  }

  static Future<Response> _executeRequest({
    required RequestType requestType,
    required Uri uri,
    required Options options,
    dynamic body,
  }) {
    return switch (requestType) {
      RequestType.get => _dio.getUri(uri, options: options),
      RequestType.post => _dio.postUri(uri, data: body, options: options),
      RequestType.put => _dio.putUri(uri, data: body, options: options),
      RequestType.patch => _dio.patchUri(uri, data: body, options: options),
      RequestType.delete => _dio.deleteUri(uri, options: options),
    };
  }

  static Either<AppFailure, dynamic> _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      AppLogger.info('Request Success ($statusCode)');
      return Either.right(response.data);
    }
    final message = _extractMessage(response.data);
    return Either.left(
      AppFailure.server(message: message, statusCode: statusCode),
    );
  }

  static AppFailure _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        AppFailure.timeout(message: Strings.serverWakingUp),
      DioExceptionType.connectionError => _mapConnectionError(error),
      DioExceptionType.cancel => AppFailure.cancelled(),
      DioExceptionType.badResponse => _handleBadResponse(error),
      _ => AppFailure.unknown(
          message: _extractMessage(
            error.response?.data,
            fallback: error.message ?? Strings.somethingWentWrong,
          ),
        ),
    };
  }

  /// Distinguishes "device offline" from "backend unreachable" (wrong host,
  /// localhost down, DNS failure for placeholder URLs, etc.).
  static AppFailure _mapConnectionError(DioException error) {
    final underlying = error.error;
    if (underlying is SocketException) {
      return _mapSocketException(underlying);
    }
    final message = (error.message ?? '').toLowerCase();
    if (_looksLikeUnreachableHost(message) || _looksLikeColdStart(message)) {
      return AppFailure.server(message: Strings.serverWakingUp);
    }
    return AppFailure.connection(message: Strings.serverWakingUp);
  }

  static AppFailure _mapSocketException(SocketException error) {
    final combined =
        '${error.message} ${error.osError?.message ?? ''}'.toLowerCase();
    if (_looksLikeUnreachableHost(combined) ||
        error.address != null ||
        combined.contains('host')) {
      return AppFailure.server(message: Strings.serverWakingUp);
    }
    return AppFailure.connection(message: Strings.serverWakingUp);
  }

  static bool _looksLikeColdStart(String message) {
    return message.contains('timed out') ||
        message.contains('timeout') ||
        message.contains('connection closed') ||
        message.contains('connection terminated');
  }

  static bool _looksLikeUnreachableHost(String message) {
    return message.contains('connection refused') ||
        message.contains('failed host lookup') ||
        message.contains('name or service not known') ||
        message.contains('no route to host') ||
        message.contains('connection reset') ||
        message.contains('software caused connection abort') ||
        message.contains('errno = 111') ||
        message.contains('errno = 61') ||
        message.contains('errno = 7');
  }

  static AppFailure _handleBadResponse(DioException error) {
    final data = error.response?.data;
    final statusCode = error.response?.statusCode ?? 0;
    final message = _extractMessage(
      data,
      fallback: error.message ?? Strings.somethingWentWrong,
    );
    return AppFailure.server(message: message, statusCode: statusCode);
  }

  /// Extracts a human-readable message from FastAPI / generic JSON bodies.
  ///
  /// Prefers FastAPI's `detail` (string or validation-error list), then
  /// `message` / `Message` / `error`, then a string body.
  static String _extractMessage(
    dynamic data, {
    String fallback = Strings.somethingWentWrong,
  }) {
    if (data == null) return fallback;

    if (data is String) {
      final trimmed = data.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }

    if (data is List) {
      final parts = data
          .map(_formatDetailItem)
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts.join('\n');
      return fallback;
    }

    if (data is Map) {
      final map = Map<Object?, Object?>.from(data);
      final detail = map['detail'] ?? map['Detail'];
      if (detail != null) {
        final fromDetail = _extractMessage(detail, fallback: '');
        if (fromDetail.isNotEmpty) return fromDetail;
      }

      for (final key in ['message', 'Message', 'error', 'Error', 'msg']) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value is List && value.isNotEmpty) {
          return value.map((e) => e.toString()).join('\n');
        }
      }
    }

    return fallback;
  }

  static String _formatDetailItem(dynamic item) {
    if (item == null) return '';
    if (item is String) return item.trim();
    if (item is Map) {
      final msg = item['msg'] ?? item['message'] ?? item['detail'];
      final loc = item['loc'];
      final location = loc is List
          ? loc.map((e) => e.toString()).where((e) => e != 'body').join('.')
          : '';
      if (msg != null) {
        final text = msg.toString().trim();
        if (text.isEmpty) return '';
        return location.isNotEmpty ? '$location: $text' : text;
      }
      return item.toString();
    }
    return item.toString();
  }

  /// Whether the user saved a non-empty server root in [SharedPrefKeys.serverBaseUrlKey].
  static bool isServerBaseUrlConfigured() {
    final saved = SharedPref.instance.getString(
      SharedPrefKeys.serverBaseUrlKey,
    );
    return saved != null && saved.trim().isNotEmpty;
  }

  /// Resolved API root for [syncResolvedMobileBaseUrl]: reads [SharedPrefKeys.serverBaseUrlKey],
  /// strips trailing `/`, then appends [kMobileAttendanceApiPrefix] unless the path
  /// already contains `MobileAttendanceServiceCore`.
  ///
  /// Returns an empty string if nothing is saved — configure the server URL first.
  static String baseUrlForRequests(String? baseUrl) {
    final root = _stripTrailingSlashes(baseUrl ?? '');
    if (root.isEmpty) return '';
    if (root.contains('MobileAttendanceServiceCore')) {
      return root;
    }
    final prefix = kMobileAttendanceApiPrefix.startsWith('/')
        ? kMobileAttendanceApiPrefix.substring(1)
        : kMobileAttendanceApiPrefix;
    return '$root/$prefix'.replaceAll(RegExp(r'/+$'), '');
  }
}
