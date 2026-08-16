import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_headers.dart';
import '../../domain/enums/humanize_mode.dart';
import '../models/audit_result_model.dart';
import '../models/check_then_humanize_result_model.dart';
import '../models/humanize_result_model.dart';
import '../models/pipeline_response_model.dart';

abstract class QualityRemoteDataSource {
  Future<Either<AppFailure, PipelineResponseModel>> runPipeline({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool runAudit,
    required bool useGemini,
  });

  Future<Either<AppFailure, HumanizeResultModel>> humanizeOnly({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool useGemini,
  });

  Future<Either<AppFailure, AuditResultModel>> auditOnly({
    required String text,
    required int timeoutSeconds,
  });

  Future<Either<AppFailure, String>> extractText(PlatformFile file);

  Future<Either<AppFailure, CheckThenHumanizeResultModel>> checkThenHumanize({
    required String text,
    required bool isArabic,
    required bool useGemini,
  });
}

class QualityRemoteDataSourceImpl implements QualityRemoteDataSource {
  QualityRemoteDataSourceImpl();

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  @override
  Future<Either<AppFailure, PipelineResponseModel>> runPipeline({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool runAudit,
    required bool useGemini,
  }) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/quality/pipeline',
        headers: await ApiHeaders.authenticatedAsync(),
        body: {
          'text': text,
          'mode': mode.apiValue,
          'language': language,
          'run_audit': runAudit,
          'use_gemini': useGemini,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          PipelineResponseModel.fromJson(_asMap(data), text),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, HumanizeResultModel>> humanizeOnly({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool useGemini,
  }) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/quality/humanize',
        headers: await ApiHeaders.authenticatedAsync(),
        body: {
          'text': text,
          'mode': mode.apiValue,
          'language': language,
          'use_gemini': useGemini,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final map = _asMap(data);
          final payload = map['humanize'] is Map
              ? _asMap(map['humanize'])
              : map;
          return Either.right(HumanizeResultModel.fromJson(payload, text));
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AuditResultModel>> auditOnly({
    required String text,
    required int timeoutSeconds,
  }) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/quality/audit',
        headers: await ApiHeaders.authenticatedAsync(),
        body: {
          'text': text,
          'timeout_seconds': timeoutSeconds,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final map = _asMap(data);
          final payload = map['audit'] is Map ? _asMap(map['audit']) : map;
          return Either.right(AuditResultModel.fromJson(payload));
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, String>> extractText(PlatformFile file) async {
    try {
      if (file.path == null) {
        return Either.left(
          AppFailure.badRequest(message: 'Selected file path is missing'),
        );
      }

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
        (data) {
          final map = _asMap(data);
          return Either.right((map['text'] as String?) ?? '');
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, CheckThenHumanizeResultModel>> checkThenHumanize({
    required String text,
    required bool isArabic,
    required bool useGemini,
  }) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/quality/check-then-humanize',
        headers: await ApiHeaders.authenticatedAsync(),
        body: {
          'text': text,
          'is_arabic': isArabic,
          'use_gemini': useGemini,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          CheckThenHumanizeResultModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }
}
