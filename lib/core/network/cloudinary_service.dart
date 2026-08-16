import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  final Dio _dio;

  CloudinaryService(this._dio);

  /// Uploads a file to Cloudinary.
  ///
  /// Features:
  /// - Enforces a local size limit of 20MB before sending.
  /// - Uses multipart/form-data upload preset `masarpro_preset` in cloud `ou96tj3r`.
  /// - Implements a max of 2 retry attempts for network failures.
  /// - Configured with 60s connect timeout and 120s send/receive timeout.
  /// - Translates Cloudinary and Network errors into clear Arabic messages.
  Future<String> uploadFile(
    File file, {
    required String folder,
    Function(double)? onProgress,
  }) async {
    // 1. Local size verification (20MB = 20 * 1024 * 1024 bytes)
    const int maxSizeBytes = 20 * 1024 * 1024;
    final int fileSize = await file.length();
    
    if (fileSize > maxSizeBytes) {
      throw Exception('حجم الملف يتجاوز الحد المسموح (20MB).');
    }

    // 2. Prepare upload request URL and Form Data
    final String cloudName = 'ou96tj3r';
    final String uploadPreset = 'masarpro_preset';
    final String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

    final String fileName = file.path.split('/').last;
    final MultipartFile multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    );

    final FormData formData = FormData.fromMap({
      'file': multipartFile,
      'upload_preset': uploadPreset,
      'folder': folder,
    });

    // 3. Configure a dedicated Dio instance for uploads
    // We isolate configuration and timeouts to prevent polluting the global Dio client,
    // and avoid sending generic app headers/interceptors to Cloudinary.
    final Dio uploadDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ));

    // Copy any global configurations/interceptors if needed (e.g. logger)
    // but exclude request authorization headers.
    for (var interceptor in _dio.interceptors) {
      // Exclude custom authorization or auth-related interceptors
      if (interceptor.runtimeType.toString().toLowerCase().contains('auth')) {
        continue;
      }
      uploadDio.interceptors.add(interceptor);
    }

    int attempt = 0;
    const int maxRetries = 2;

    while (true) {
      try {
        attempt++;
        debugPrint('CloudinaryService: Upload attempt $attempt of ${maxRetries + 1} for file: $fileName');

        final response = await uploadDio.post(
          uploadUrl,
          data: formData,
          onSendProgress: (sent, total) {
            if (onProgress != null && total > 0) {
              final double progress = sent / total;
              onProgress(progress);
            }
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final secureUrl = response.data['secure_url'] as String?;
          if (secureUrl != null && secureUrl.isNotEmpty) {
            debugPrint('CloudinaryService: Upload success. URL: $secureUrl');
            return secureUrl;
          }
        }
        
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      } catch (e) {
        // Check if we should retry (only on network/connection errors, not on validation or quota failures)
        final bool isNetworkError = _isNetworkError(e);
        
        if (isNetworkError && attempt <= maxRetries) {
          debugPrint('CloudinaryService: Network error encountered on attempt $attempt. Retrying...');
          // Optional short delay before retry
          await Future.delayed(Duration(seconds: 2 * attempt));
          continue;
        }

        // Rethrow translated exception
        throw _translateException(e);
      } finally {
        uploadDio.close();
      }
    }
  }

  /// Determines if the error is a network connectivity issue / timeout
  bool _isNetworkError(dynamic e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          (e.type == DioExceptionType.unknown && e.error is SocketException);
    }
    return false;
  }

  /// Translates network and Cloudinary exceptions to human-readable Arabic messages.
  Exception _translateException(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Exception('انتهت مهلة الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مجدداً.');
      }

      if (e.type == DioExceptionType.connectionError) {
        return Exception('خطأ في الاتصال بالشبكة. يرجى التأكد من اتصالك بالإنترنت.');
      }

      if (e.type == DioExceptionType.badResponse) {
        final responseData = e.response?.data;
        if (responseData is Map && responseData['error'] != null) {
          final message = responseData['error']['message']?.toString() ?? '';
          debugPrint('Cloudinary Error message: $message');
          
          if (message.contains('Limit exceeded') || message.contains('quota')) {
            return Exception('تم تجاوز الحد المسموح به للمساحة التخزينية المجانية على Cloudinary.');
          }
          if (message.contains('Invalid image file') || message.contains('not supported')) {
            return Exception('صيغة الملف غير مدعومة أو الملف تالف.');
          }
          return Exception('فشل رفع الملف: $message');
        }
        return Exception('فشل الرفع بسبب استجابة غير صالحة من الخادم (${e.response?.statusCode}).');
      }
    }
    
    if (e is Exception) {
      return e;
    }
    return Exception('حدث خطأ غير متوقع أثناء رفع الملف: ${e.toString()}');
  }
}
