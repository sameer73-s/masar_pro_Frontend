import 'package:file_picker/file_picker.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../entities/evidence.dart';
import '../entities/journal_match.dart';
import '../entities/manuscript_version.dart';
import '../entities/readiness_report.dart';
import '../entities/research_project.dart';
import '../entities/response_item.dart';
import '../entities/reviewer_comment.dart';
import '../entities/revision.dart';
import '../entities/submission.dart';

abstract class PublishingRepository {
  Future<Either<AppFailure, List<ResearchProject>>> getResearchProjects();

  Future<Either<AppFailure, ResearchProject>> createResearch(String title);

  Future<Either<AppFailure, ManuscriptVersion>> uploadManuscript(
    String projectId,
    PlatformFile file,
  );

  Future<Either<AppFailure, ReadinessReport>> analyzeReadiness(String projectId);

  Future<Either<AppFailure, List<JournalMatch>>> matchJournals(String projectId);

  Future<Either<AppFailure, String>> prepareManuscript(
    String projectId,
    String journalId,
  );

  Future<Either<AppFailure, Submission>> createSubmission(
    String projectId,
    String journalId,
    String submissionId,
  );

  Future<Either<AppFailure, SubmissionDetails>> getSubmissionDetails(
    String projectId,
  );

  Future<Either<AppFailure, Evidence>> addEvidence(
    String submissionId,
    PlatformFile file,
  );

  Future<Either<AppFailure, List<ReviewerComment>>> getComments(
    String submissionId,
  );

  Future<Either<AppFailure, List<ReviewerComment>>> addComments(
    String submissionId,
    List<String> comments,
  );

  Future<Either<AppFailure, List<ResponseItem>>> generateResponses(
    String submissionId,
  );

  Future<Either<AppFailure, Revision>> uploadRevision(
    String submissionId,
    PlatformFile file,
  );
}
