import '../enums/research_status.dart';
import 'sub_agent_status.dart';

class ResearchProgress {
  final String jobId;
  final ResearchStatus status;
  final int progressPct; // 0-100
  final String currentStep; // رسالة من الخادم
  final String? currentSection; // اسم الفصل الذي يُكتب الآن
  final int sectionsDone;
  final int sectionsTotal;
  final List<SubAgentStatus> subAgents;

  const ResearchProgress({
    required this.jobId,
    required this.status,
    required this.progressPct,
    required this.currentStep,
    this.currentSection,
    required this.sectionsDone,
    required this.sectionsTotal,
    this.subAgents = const [],
  });

  ResearchProgress copyWith({
    String? jobId,
    ResearchStatus? status,
    int? progressPct,
    String? currentStep,
    String? currentSection,
    int? sectionsDone,
    int? sectionsTotal,
    List<SubAgentStatus>? subAgents,
  }) {
    return ResearchProgress(
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      progressPct: progressPct ?? this.progressPct,
      currentStep: currentStep ?? this.currentStep,
      currentSection: currentSection ?? this.currentSection,
      sectionsDone: sectionsDone ?? this.sectionsDone,
      sectionsTotal: sectionsTotal ?? this.sectionsTotal,
      subAgents: subAgents ?? this.subAgents,
    );
  }
}
