import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_headers.dart';
import '../../domain/enums/academic_phase.dart';
import '../models/academic_project_model.dart';

abstract class AcademicProjectRemoteDataSource {
  Future<Either<AppFailure, AcademicProjectModel>> createProject({
    required String title,
    required String academicLevel,
    required String language,
    String? university,
  });

  Future<Either<AppFailure, List<AcademicProjectModel>>> getProjects();

  Future<Either<AppFailure, AcademicProjectModel>> getProjectDetails(String id);

  Future<Either<AppFailure, AcademicProjectModel>> updatePhaseStatus(
    String id,
    AcademicPhase phase,
    String status,
  );

  Future<Either<AppFailure, AcademicProjectModel>> uploadProposal(
    String projectId,
    File file,
  );

  Future<Either<AppFailure, AcademicProjectModel>> generateProposal(
    String projectId,
  );

  Future<Either<AppFailure, AcademicProjectModel>> approveProposal(
    String projectId,
  );

  Future<Either<AppFailure, AcademicProjectModel>> skipProposal(
    String projectId,
  );

  Future<Either<AppFailure, AcademicProjectModel>> uploadResearch(
    String projectId,
    File file,
  );

  Future<Either<AppFailure, AcademicProjectModel>> approveResearch(
    String projectId,
  );

  Future<Either<AppFailure, String>> startPublishing(String projectId);

  Future<Either<AppFailure, String>> submitFeedback({
    required String projectId,
    required String feedbackText,
    required String instructions,
    required String source,
  });
}

class AcademicProjectRemoteDataSourceImpl
    implements AcademicProjectRemoteDataSource {
  AcademicProjectRemoteDataSourceImpl();

  static const _base = '/api/v1/academic-projects';

  Future<Map<String, String>> _authHeaders() =>
      ApiHeaders.authenticatedAsync();

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final nested = data['projects'] ?? data['data'] ?? data['items'];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  String _fileName(File file) {
    final parts = file.path.replaceAll('\\', '/').split('/');
    final name = parts.isNotEmpty ? parts.last : '';
    return name.trim().isEmpty ? 'proposal.pdf' : name;
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> createProject({
    required String title,
    required String academicLevel,
    required String language,
    String? university,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'academic_level': academicLevel,
        'language': language,
      };
      if (university != null && university.trim().isNotEmpty) {
        body['university'] = university.trim();
      }

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: _base,
        headers: await _authHeaders(),
        body: body,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<AcademicProjectModel>>> getProjects() async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.get,
        endPoint: _base,
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final list = _asMapList(data);
          return Either.right(
            list.map(AcademicProjectModel.fromJson).toList(),
          );
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> getProjectDetails(
    String id,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.get,
        endPoint: '$_base/$id',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> updatePhaseStatus(
    String id,
    AcademicPhase phase,
    String status,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.patch,
        endPoint: '$_base/$id/status',
        headers: await _authHeaders(),
        body: {
          'phase': phase.apiValue,
          'status': status,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> uploadProposal(
    String projectId,
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
      });

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/$projectId/proposal/upload',
        headers: await _authHeaders(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> generateProposal(
    String projectId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/$projectId/proposal/generate',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> approveProposal(
    String projectId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/$projectId/proposal/approve',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> skipProposal(
    String projectId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/$projectId/proposal/skip',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> uploadResearch(
    String projectId,
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
      });

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/$projectId/research/upload',
        headers: await _authHeaders(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AcademicProjectModel>> approveResearch(
    String projectId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/$projectId/research/approve',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AcademicProjectModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, String>> startPublishing(String projectId) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/$projectId/publish/start',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final map = _asMap(data);
          final pubProjectId =
              (map['pub_project_id'] ?? map['pubProjectId'] ?? '')
                  .toString()
                  .trim();
          if (pubProjectId.isEmpty) {
            return Either.left(
              AppFailure.server(
                message: 'Start publishing response missing pub_project_id',
              ),
            );
          }
          return Either.right(pubProjectId);
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, String>> submitFeedback({
    required String projectId,
    required String feedbackText,
    required String instructions,
    required String source,
  }) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/$projectId/feedback',
        headers: await _authHeaders(),
        body: {
          'feedback_text': feedbackText,
          'instructions': instructions,
          'source': source,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final map = _asMap(data);
          final fileUrl =
              (map['file_url'] ?? map['fileUrl'] ?? '').toString().trim();
          if (fileUrl.isEmpty) {
            return Either.left(
              AppFailure.server(message: 'Feedback response missing file_url'),
            );
          }
          return Either.right(fileUrl);
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }
}
