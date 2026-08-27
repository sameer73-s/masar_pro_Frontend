import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_headers.dart';
import '../models/evidence_model.dart';
import '../models/journal_match_model.dart';
import '../models/manuscript_version_model.dart';
import '../models/readiness_report_model.dart';
import '../models/research_project_model.dart';
import '../models/response_item_model.dart';
import '../models/reviewer_comment_model.dart';
import '../models/revision_model.dart';
import '../models/submission_model.dart';

abstract class PublishingRemoteDataSource {
  Future<Either<AppFailure, List<ResearchProjectModel>>> getResearchProjects();

  Future<Either<AppFailure, ResearchProjectModel>> createResearch(String title);

  Future<Either<AppFailure, void>> deleteResearchProject(String projectId);

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

  Future<Either<AppFailure, String>> prepareManuscript(
    String projectId,
    String journalId,
  );

  Future<Either<AppFailure, SubmissionModel>> createSubmission(
    String projectId,
    String journalId,
    String submissionId,
  );

  Future<Either<AppFailure, SubmissionDetailsModel>> getSubmissionDetails(
    String projectId,
  );

  Future<Either<AppFailure, EvidenceModel>> addEvidence(
    String submissionId,
    PlatformFile file,
  );

  Future<Either<AppFailure, List<ReviewerCommentModel>>> getComments(
    String submissionId,
  );

  Future<Either<AppFailure, List<ReviewerCommentModel>>> addComments(
    String submissionId,
    List<String> comments,
  );

  Future<Either<AppFailure, List<ResponseItemModel>>> generateResponses(
    String submissionId,
  );

  Future<Either<AppFailure, RevisionModel>> uploadRevision(
    String submissionId,
    PlatformFile file,
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
  Future<Either<AppFailure, void>> deleteResearchProject(
    String projectId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.delete,
        endPoint: '$_base/research/$projectId',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
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

  @override
  Future<Either<AppFailure, String>> prepareManuscript(
    String projectId,
    String journalId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/research/$projectId/prepare-manuscript',
        headers: await _authHeaders(),
        body: {'journal_id': journalId},
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final packageUrl = _extractPackageUrl(data);
          if (packageUrl == null || packageUrl.isEmpty) {
            return Either.left(
              AppFailure.server(
                message: 'Manuscript package URL missing from response.',
              ),
            );
          }
          return Either.right(packageUrl);
        },
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

  @override
  Future<Either<AppFailure, SubmissionModel>> createSubmission(
    String projectId,
    String journalId,
    String submissionId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/research/$projectId/submission',
        headers: await _authHeaders(),
        body: {
          'journal_id': journalId,
          'submission_id': submissionId,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          SubmissionModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, SubmissionDetailsModel>> getSubmissionDetails(
    String projectId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.get,
        endPoint: '$_base/research/$projectId/submission',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          SubmissionDetailsModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, EvidenceModel>> addEvidence(
    String submissionId,
    PlatformFile file,
  ) async {
    try {
      final multipartFile = await _toMultipartFile(file);
      final inferredType = _inferEvidenceType(file.name);
      final formData = FormData.fromMap({
        'file': multipartFile,
        if (inferredType != null) 'file_type': inferredType,
      });

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/submissions/$submissionId/evidence',
        headers: await _authHeaders(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          EvidenceModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<ReviewerCommentModel>>> getComments(
    String submissionId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.get,
        endPoint: '$_base/submissions/$submissionId/responses',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(_parseComments(data)),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<ReviewerCommentModel>>> addComments(
    String submissionId,
    List<String> comments,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/submissions/$submissionId/comments',
        headers: await _authHeaders(),
        body: {'comments': comments},
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(_parseAddedComments(data)),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<ResponseItemModel>>> generateResponses(
    String submissionId,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/submissions/$submissionId/generate-responses',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(_parseResponseItems(data)),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, RevisionModel>> uploadRevision(
    String submissionId,
    PlatformFile file,
  ) async {
    try {
      final multipartFile = await _toMultipartFile(file);
      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/submissions/$submissionId/revision',
        headers: await _authHeaders(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          RevisionModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  List<ReviewerCommentModel> _parseComments(dynamic data) {
    final raw = _listFrom(data, const ['items', 'comments']);
    return raw
        .whereType<Map>()
        .map(
          (item) => ReviewerCommentModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  List<ReviewerCommentModel> _parseAddedComments(dynamic data) {
    final raw = _listFrom(data, const ['comments', 'items']);
    return raw
        .whereType<Map>()
        .map(
          (item) => ReviewerCommentModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  List<ResponseItemModel> _parseResponseItems(dynamic data) {
    final raw = _listFrom(data, const ['items', 'responses']);
    return raw
        .whereType<Map>()
        .map(
          (item) => ResponseItemModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  List<dynamic> _listFrom(dynamic data, List<String> keys) {
    if (data is List) return data;
    final map = _asMap(data);
    for (final key in keys) {
      final raw = map[key];
      if (raw is List) return raw;
    }
    return const [];
  }

  String? _inferEvidenceType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return 'EMAIL_PDF';
    const imageSuffixes = ['.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp'];
    if (imageSuffixes.any(lower.endsWith)) return 'SCREENSHOT';
    return null;
  }

  String? _extractPackageUrl(dynamic data) {
    final map = _asMap(data);
    final direct = map['package_url'] ??
        map['packageUrl'] ??
        map['download_url'] ??
        map['downloadUrl'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }

    final manuscript = _asMap(map['manuscript']);
    final manuscriptUrl =
        manuscript['download_url'] ?? manuscript['downloadUrl'];
    if (manuscriptUrl != null && manuscriptUrl.toString().trim().isNotEmpty) {
      return manuscriptUrl.toString().trim();
    }

    final letter = _asMap(map['cover_letter'] ?? map['coverLetter']);
    final letterUrl = letter['download_url'] ?? letter['downloadUrl'];
    if (letterUrl != null && letterUrl.toString().trim().isNotEmpty) {
      return letterUrl.toString().trim();
    }
    return null;
  }
}
