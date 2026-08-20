import 'package:file_picker/file_picker.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/journal_match.dart';
import '../../domain/entities/manuscript_version.dart';
import '../../domain/entities/readiness_report.dart';
import '../../domain/entities/research_project.dart';
import '../../domain/entities/response_item.dart';
import '../../domain/entities/reviewer_comment.dart';
import '../../domain/entities/revision.dart';
import '../../domain/entities/submission.dart';
import '../../domain/repositories/publishing_repository.dart';
import '../datasources/publishing_remote_datasource.dart';

class PublishingRepositoryImpl extends BaseRepository
    implements PublishingRepository {
  final PublishingRemoteDataSource remoteDataSource;

  PublishingRepositoryImpl({
    required super.networkService,
    required this.remoteDataSource,
  });

  @override
  Future<Either<AppFailure, List<ResearchProject>>> getResearchProjects() async {
    return guardedCall(() async {
      final result = await remoteDataSource.getResearchProjects();
      return result.fold(
        (failure) => Either.left(failure),
        (models) => Either.right(models),
      );
    });
  }

  @override
  Future<Either<AppFailure, ResearchProject>> createResearch(
    String title,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.createResearch(title);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, ManuscriptVersion>> uploadManuscript(
    String projectId,
    PlatformFile file,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.uploadManuscript(projectId, file);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, ReadinessReport>> analyzeReadiness(
    String projectId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.analyzeReadiness(projectId);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, List<JournalMatch>>> matchJournals(
    String projectId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.matchJournals(projectId);
      return result.fold(
        (failure) => Either.left(failure),
        (models) => Either.right(models),
      );
    });
  }

  @override
  Future<Either<AppFailure, String>> prepareManuscript(
    String projectId,
    String journalId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.prepareManuscript(
        projectId,
        journalId,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (packageUrl) => Either.right(packageUrl),
      );
    });
  }

  @override
  Future<Either<AppFailure, Submission>> createSubmission(
    String projectId,
    String journalId,
    String submissionId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.createSubmission(
        projectId,
        journalId,
        submissionId,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, SubmissionDetails>> getSubmissionDetails(
    String projectId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.getSubmissionDetails(projectId);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, Evidence>> addEvidence(
    String submissionId,
    PlatformFile file,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.addEvidence(submissionId, file);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, List<ReviewerComment>>> getComments(
    String submissionId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.getComments(submissionId);
      return result.fold(
        (failure) => Either.left(failure),
        (models) => Either.right(models),
      );
    });
  }

  @override
  Future<Either<AppFailure, List<ReviewerComment>>> addComments(
    String submissionId,
    List<String> comments,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.addComments(submissionId, comments);
      return result.fold(
        (failure) => Either.left(failure),
        (models) => Either.right(models),
      );
    });
  }

  @override
  Future<Either<AppFailure, List<ResponseItem>>> generateResponses(
    String submissionId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.generateResponses(submissionId);
      return result.fold(
        (failure) => Either.left(failure),
        (models) => Either.right(models),
      );
    });
  }

  @override
  Future<Either<AppFailure, Revision>> uploadRevision(
    String submissionId,
    PlatformFile file,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.uploadRevision(submissionId, file);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }
}
