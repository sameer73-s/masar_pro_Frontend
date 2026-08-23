import 'dart:io';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../entities/academic_project.dart';
import '../enums/academic_phase.dart';

abstract class AcademicProjectRepository {
  Future<Either<AppFailure, AcademicProject>> createProject({
    required String title,
    required String academicLevel,
    required String language,
    String? university,
  });

  Future<Either<AppFailure, List<AcademicProject>>> getProjects();

  Future<Either<AppFailure, AcademicProject>> getProjectDetails(String id);

  Future<Either<AppFailure, AcademicProject>> updatePhaseStatus(
    String id,
    AcademicPhase phase,
    String status,
  );

  Future<Either<AppFailure, AcademicProject>> uploadProposal(
    String projectId,
    File file,
  );

  Future<Either<AppFailure, AcademicProject>> approveProposal(String projectId);

  Future<Either<AppFailure, String>> submitFeedback({
    required String projectId,
    required String feedbackText,
    required String instructions,
    required String source,
  });
}
