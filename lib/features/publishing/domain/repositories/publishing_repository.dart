import 'package:file_picker/file_picker.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../entities/journal_match.dart';
import '../entities/manuscript_version.dart';
import '../entities/readiness_report.dart';
import '../entities/research_project.dart';

abstract class PublishingRepository {
  Future<Either<AppFailure, List<ResearchProject>>> getResearchProjects();

  Future<Either<AppFailure, ResearchProject>> createResearch(String title);

  Future<Either<AppFailure, ManuscriptVersion>> uploadManuscript(
    String projectId,
    PlatformFile file,
  );

  Future<Either<AppFailure, ReadinessReport>> analyzeReadiness(String projectId);

  Future<Either<AppFailure, List<JournalMatch>>> matchJournals(String projectId);
}
