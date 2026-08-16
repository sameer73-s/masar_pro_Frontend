import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_headers.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';

abstract class ContentCreationRemoteDataSource {
  Future<Either<AppFailure, Map<String, dynamic>>> createContent({
    required String taskType,
    required String title,
    required Map<String, dynamic> optionalFields,
  });

  Future<Either<AppFailure, String>> extractText(PlatformFile file);

  Future<Either<AppFailure, Map<String, dynamic>>> checkThenHumanize({
    required String text,
    required bool isArabic,
    required bool useGemini,
  });
}

class ContentCreationRemoteDataSourceImpl implements ContentCreationRemoteDataSource {
  ContentCreationRemoteDataSourceImpl();

  @override
  Future<Either<AppFailure, Map<String, dynamic>>> createContent({
    required String taskType,
    required String title,
    required Map<String, dynamic> optionalFields,
  }) async {
    try {
      final payload = {
        'task_type': taskType,
        'title': title,
        'optional_fields': optionalFields,
      };

      final headers = await ApiHeaders.authenticatedAsync();
      debugPrint(
        '[ContentCreationRemote] POST /api/v1/create-content '
        'auth=${headers.containsKey('Authorization')} taskType=$taskType',
      );
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/create-content',
        headers: headers,
        body: payload,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(Map<String, dynamic>.from(data)),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, String>> extractText(PlatformFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/quality/extract-text',
        headers: await ApiHeaders.authenticatedAsync(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(data['text'] ?? ""),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, Map<String, dynamic>>> checkThenHumanize({
    required String text,
    required bool isArabic,
    required bool useGemini,
  }) async {
    try {
      final payload = {
        'text': text,
        'is_arabic': isArabic,
        'use_gemini': useGemini,
      };

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/quality/check-then-humanize',
        headers: await ApiHeaders.authenticatedAsync(),
        body: payload,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(Map<String, dynamic>.from(data)),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }
}
