import '../../domain/entities/research_job.dart';
import '../../domain/entities/research_progress.dart';
import '../../domain/entities/sub_agent_status.dart';

abstract class ResearchState {}

class ResearchInitial extends ResearchState {}

class ResearchFormReady extends ResearchState {
  final List<ResearchJob> history;
  ResearchFormReady({required this.history});
}

/// بعد الضغط → loading قصير
class ResearchStarting extends ResearchState {}

class ResearchInProgress extends ResearchState {
  final ResearchProgress progress;

  ResearchInProgress(this.progress);

  /// Parallel research workers (empty outside researching stage).
  List<SubAgentStatus> get subAgents => progress.subAgents;
}

class ResearchDownloading extends ResearchState {
  final ResearchProgress progress;
  ResearchDownloading(this.progress);
}

class ResearchDownloadReady extends ResearchState {
  final String localFilePath;
  final ResearchProgress finalProgress;
  ResearchDownloadReady({
    required this.localFilePath,
    required this.finalProgress,
  });
}

class ResearchFailed extends ResearchState {
  final String message;
  final String? jobId; // للسماح بإعادة الاتصال
  ResearchFailed({required this.message, this.jobId});
}
