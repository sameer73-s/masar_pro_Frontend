import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_headers.dart';
import '../models/journal_match_model.dart';
import '../models/manuscript_version_model.dart';
import '../models/readiness_report_model.dart';
import '../models/research_project_model.dart';

abstract class PublishingRemoteDataSource {
  Future<Either<AppFailure, List<ResearchProjectModel>>> getResearchProjects();

  Future<Either<AppFailure, ResearchProjectModel>> createResearch(String title);

  Future<Either<AppFailure, ManuscriptVersionModel>> uploadManuscript(
    String projectId,
    PlatformFile file,
  );

  Future<Either<AppFailure, ReadinessReportModel>> analyzeReadiness(
    String projectId,
  );

  Future<Either<AppFailure, List<JournalMatchModel>>> matchJournals(
    String projectId,
  );
}

class PublishingRemoteDataSourceImpl implements PublishingRemoteDataSource {
  PublishingRemoteDataSourceImpl();

  static const _base = '/api/v1/publishing';

  Future<Map<String, String>> _authHeaders() =>
      ApiHeaders.authenticatedAsync();

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  Future<MultipartFile> _toMultipartFile(PlatformFile file) async {
    if (file.path != null) {
      return MultipartFile.fromFile(file.path!, filename: file.name);
    }
    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    }
    throw Exception('Selected manuscript file is empty or invalid.');
  }

  @override
  Future<Either<AppFailure, List<ResearchProjectModel>>> getResearchProjects() async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.get,
        endPoint: '$_base/research',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(_parseProjects(data)),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, ResearchProjectModel>> createResearch(
    String title,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/research',
        headers: await _authHeaders(),
        body: {'title': title, 'language': 'arabic'},
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          ResearchProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, ManuscriptVersionModel>> uploadManuscript(
    String projectId,
    PlatformFile file,
  ) async {
    try {
      final multipartFile = await _toMultipartFile(file);
      final formData = FormData.fromMap({
        'file': multipartFile,
        'file_type': 'ORIGINAL',
      });

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/research/$projectId/upload-manuscript',
        headers: await _authHeaders(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          ManuscriptVersionModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, ReadinessReportModel>> analyzeReadiness(
    String projectId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/research/$projectId/analyze-readiness',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          ReadinessReportModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<JournalMatchModel>>> matchJournals(
    String projectId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/research/$projectId/match-journals',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(_parseMatches(data)),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  List<ResearchProjectModel> _parseProjects(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => ResearchProjectModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    final map = _asMap(data);
    final raw = map['projects'] ?? map['items'] ?? map['data'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) => ResearchProjectModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return const [];
  }

  List<JournalMatchModel> _parseMatches(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => JournalMatchModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    final map = _asMap(data);
    final raw = map['matches'] ?? map['journals'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) => JournalMatchModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return const [];
  }
}
