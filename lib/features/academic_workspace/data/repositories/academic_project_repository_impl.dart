import 'dart:io';

import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../domain/entities/academic_project.dart';
import '../../domain/enums/academic_phase.dart';
import '../../domain/repositories/academic_project_repository.dart';
import '../datasources/academic_project_remote_datasource.dart';

class AcademicProjectRepositoryImpl extends BaseRepository
    implements AcademicProjectRepository {
  final AcademicProjectRemoteDataSource remoteDataSource;

  AcademicProjectRepositoryImpl({
    required super.networkService,
    required this.remoteDataSource,
  });

  @override
  Future<Either<AppFailure, AcademicProject>> createProject({
    required String title,
    required String academicLevel,
    required String language,
    String? university,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.createProject(
        title: title,
        academicLevel: academicLevel,
        language: language,
        university: university,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, List<AcademicProject>>> getProjects() async {
    return guardedCall(() async {
      final result = await remoteDataSource.getProjects();
      return result.fold(
        (failure) => Either.left(failure),
        (models) => Either.right(models.cast<AcademicProject>()),
      );
    });
  }

  @override
  Future<Either<AppFailure, AcademicProject>> getProjectDetails(
    String id,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.getProjectDetails(id);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AcademicProject>> updatePhaseStatus(
    String id,
    AcademicPhase phase,
    String status,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.updatePhaseStatus(
        id,
        phase,
        status,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AcademicProject>> uploadProposal(
    String projectId,
    File file,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.uploadProposal(projectId, file);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AcademicProject>> generateProposal(
    String projectId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.generateProposal(projectId);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AcademicProject>> approveProposal(
    String projectId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.approveProposal(projectId);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AcademicProject>> skipProposal(
    String projectId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.skipProposal(projectId);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AcademicProject>> uploadResearch(
    String projectId,
    File file,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.uploadResearch(projectId, file);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AcademicProject>> approveResearch(
    String projectId,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.approveResearch(projectId);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, String>> submitFeedback({
    required String projectId,
    required String feedbackText,
    required String instructions,
    required String source,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.submitFeedback(
        projectId: projectId,
        feedbackText: feedbackText,
        instructions: instructions,
        source: source,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (fileUrl) => Either.right(fileUrl),
      );
    });
  }
}
