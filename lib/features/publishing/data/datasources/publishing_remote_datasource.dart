import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_headers.dart';
import '../models/automated_submission_model.dart';
import 'submission_socket_connector.dart';
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

  Future<Either<AppFailure, AutomatedSubmissionJobModel>>
  startAutomatedSubmission({
    required String projectId,
    required String journalId,
    required String targetUrl,
    required String fileId,
  });

  Stream<SubmissionProgressUpdateModel> watchAutomatedSubmission(String jobId);

  Future<void> closeAutomatedSubmissionWatch();
}

class PublishingRemoteDataSourceImpl implements PublishingRemoteDataSource {
  PublishingRemoteDataSourceImpl();

  static const _base = '/api/v1/publishing';

  WebSocketChannel? _submissionChannel;
  StreamSubscription<dynamic>? _submissionSocketSubscription;
  StreamController<SubmissionProgressUpdateModel>? _submissionController;

  Future<Map<String, String>> _authHeaders() => ApiHeaders.authenticatedAsync();

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
  Future<Either<AppFailure, AutomatedSubmissionJobModel>>
  startAutomatedSubmission({
    required String projectId,
    required String journalId,
    required String targetUrl,
    required String fileId,
  }) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/submit-automated',
        headers: await _authHeaders(),
        body: {
          'project_id': projectId,
          'journal_id': journalId,
          'target_url': targetUrl,
          'file_id': fileId,
          'mode': 'dry_run',
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) =>
            Either.right(AutomatedSubmissionJobModel.fromJson(_asMap(data))),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Stream<SubmissionProgressUpdateModel> watchAutomatedSubmission(String jobId) {
    unawaited(closeAutomatedSubmissionWatch());

    final controller = StreamController<SubmissionProgressUpdateModel>(
      onCancel: closeAutomatedSubmissionWatch,
    );
    _submissionController = controller;

    () async {
      try {
        final headers = await _authHeaders();
        final authorization = headers['Authorization'];
        final channel = await connectAuthenticatedSubmissionSocket(
          _submissionProgressUri(jobId),
          headers: {
            if (authorization != null && authorization.isNotEmpty)
              'Authorization': authorization,
          },
        );
        _submissionChannel = channel;

        if (_submissionChannel != channel || controller.isClosed) {
          await channel.sink.close();
          return;
        }

        _submissionSocketSubscription = channel.stream.listen(
          (raw) {
            final model = _mapSubmissionSocketMessage(raw);
            if (model == null || controller.isClosed) return;
            controller.add(model);
            if (_isTerminal(model.state)) {
              unawaited(_finishSubmissionTerminal(controller));
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!controller.isClosed) controller.addError(error, stackTrace);
          },
          onDone: () {
            if (!controller.isClosed) unawaited(controller.close());
            unawaited(_teardownSubmissionSocket());
          },
          cancelOnError: false,
        );
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
          await controller.close();
        }
        await _teardownSubmissionSocket();
      }
    }();

    return controller.stream;
  }

  @override
  Future<void> closeAutomatedSubmissionWatch() async {
    final controller = _submissionController;
    await _teardownSubmissionSocket();
    if (controller != null && !controller.isClosed) await controller.close();
    if (identical(_submissionController, controller)) {
      _submissionController = null;
    }
  }

  static Uri _submissionProgressUri(String jobId) {
    final httpBase = ApiConfig.normalizedBaseUrl;
    final wsBase = httpBase
        .replaceFirst(RegExp(r'^https://', caseSensitive: false), 'wss://')
        .replaceFirst(RegExp(r'^http://', caseSensitive: false), 'ws://');
    return Uri.parse('$wsBase/api/v1/publishing/submission-jobs/$jobId/events');
  }

  SubmissionProgressUpdateModel? _mapSubmissionSocketMessage(dynamic raw) {
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! Map) return null;
      return SubmissionProgressUpdateModel.fromEnvelope(decoded);
    } catch (_) {
      return null;
    }
  }

  bool _isTerminal(String state) =>
      const {'COMPLETED', 'FAILED', 'CANCELLED'}.contains(state.toUpperCase());

  Future<void> _finishSubmissionTerminal(
    StreamController<SubmissionProgressUpdateModel> controller,
  ) async {
    await _teardownSubmissionSocket();
    if (!controller.isClosed) await controller.close();
  }

  Future<void> _teardownSubmissionSocket() async {
    final subscription = _submissionSocketSubscription;
    _submissionSocketSubscription = null;
    await subscription?.cancel();

    final channel = _submissionChannel;
    _submissionChannel = null;
    if (channel != null) {
      try {
        await channel.sink.close();
      } catch (_) {}
    }
  }

  @override
  Future<Either<AppFailure, List<ResearchProjectModel>>>
  getResearchProjects() async {
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
        (data) => Either.right(ResearchProjectModel.fromJson(_asMap(data))),
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
        (data) => Either.right(ManuscriptVersionModel.fromJson(_asMap(data))),
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
        (data) => Either.right(ReadinessReportModel.fromJson(_asMap(data))),
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

      return response.fold((failure) => Either.left(failure), (data) {
        final packageUrl = _extractPackageUrl(data);
        if (packageUrl == null || packageUrl.isEmpty) {
          return Either.left(
            AppFailure.server(
              message: 'Manuscript package URL missing from response.',
            ),
          );
        }
        return Either.right(packageUrl);
      });
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  List<ResearchProjectModel> _parseProjects(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) =>
                ResearchProjectModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    final map = _asMap(data);
    final raw = map['projects'] ?? map['items'] ?? map['data'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) =>
                ResearchProjectModel.fromJson(Map<String, dynamic>.from(item)),
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
            (item) =>
                JournalMatchModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    final map = _asMap(data);
    final raw = map['matches'] ?? map['journals'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) =>
                JournalMatchModel.fromJson(Map<String, dynamic>.from(item)),
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
        body: {'journal_id': journalId, 'submission_id': submissionId},
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(SubmissionModel.fromJson(_asMap(data))),
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
        (data) => Either.right(SubmissionDetailsModel.fromJson(_asMap(data))),
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
        (data) => Either.right(EvidenceModel.fromJson(_asMap(data))),
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
      final formData = FormData.fromMap({'file': multipartFile});

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '$_base/submissions/$submissionId/revision',
        headers: await _authHeaders(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(RevisionModel.fromJson(_asMap(data))),
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
          (item) =>
              ReviewerCommentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  List<ReviewerCommentModel> _parseAddedComments(dynamic data) {
    final raw = _listFrom(data, const ['comments', 'items']);
    return raw
        .whereType<Map>()
        .map(
          (item) =>
              ReviewerCommentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  List<ResponseItemModel> _parseResponseItems(dynamic data) {
    final raw = _listFrom(data, const ['items', 'responses']);
    return raw
        .whereType<Map>()
        .map(
          (item) => ResponseItemModel.fromJson(Map<String, dynamic>.from(item)),
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
    final direct =
        map['package_url'] ??
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
