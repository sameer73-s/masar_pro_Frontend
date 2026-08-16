import 'package:file_picker/file_picker.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../domain/entities/journal_match.dart';
import '../../domain/entities/manuscript_version.dart';
import '../../domain/entities/readiness_report.dart';
import '../../domain/entities/research_project.dart';
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
}
