import '../../domain/entities/research_progress.dart';
import '../../domain/entities/sub_agent_status.dart';
import '../../domain/enums/research_status.dart';

class SubAgentStatusModel {
  final String id;
  final String status;
  final String section;
  final String message;

  const SubAgentStatusModel({
    required this.id,
    required this.status,
    required this.section,
    required this.message,
  });

  /// Parse backend `subagent_status` data payload.
  factory SubAgentStatusModel.fromWs(Map<String, dynamic> json) {
    final description = json['description'] as String? ?? '';
    final error = json['error'] as String?;
    final section = _extractSection(description) ??
        (json['subagent_name'] as String? ?? 'عامل بحث');

    return SubAgentStatusModel(
      id: json['task_id'] as String? ??
          json['subagent_name'] as String? ??
          UniqueKeyFallback.id(json),
      status: json['status'] as String? ?? 'pending',
      section: section,
      message: (error != null && error.isNotEmpty) ? error : description,
    );
  }

  SubAgentStatus toEntity() => SubAgentStatus(
        id: id,
        status: status,
        section: section,
        message: message,
      );

  static String? _extractSection(String description) {
    final patterns = <RegExp>[
      RegExp(r'researching:\s*(.+)$', caseSensitive: false),
      RegExp(r'done:\s*(.+?)(?:\s*\(|$)', caseSensitive: false),
      RegExp(r'failed:\s*(.+)$', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(description);
      final value = match?.group(1)?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}

/// Tiny helper when task_id is missing (should be rare).
class UniqueKeyFallback {
  static int _n = 0;
  static String id(Map<String, dynamic> json) {
    _n += 1;
    return 'worker_${json.hashCode}_$_n';
  }
}

class ResearchProgressModel {
  final String jobId;
  final ResearchStatus status;
  final int progressPct;
  final String currentStep;
  final String? currentSection;
  final int sectionsDone;
  final int sectionsTotal;
  final List<SubAgentStatusModel> subAgents;

  const ResearchProgressModel({
    required this.jobId,
    required this.status,
    required this.progressPct,
    required this.currentStep,
    this.currentSection,
    required this.sectionsDone,
    required this.sectionsTotal,
    this.subAgents = const [],
  });

  factory ResearchProgressModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) => (value as num?)?.toInt() ?? 0;

    final rawAgents = json['sub_agents'] ?? json['subAgents'];
    final agents = <SubAgentStatusModel>[];
    if (rawAgents is List) {
      for (final item in rawAgents) {
        if (item is Map) {
          agents.add(
            SubAgentStatusModel.fromWs(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return ResearchProgressModel(
      jobId: json['job_id'] as String? ?? '',
      status: ResearchStatus.fromApi(json['status'] as String? ?? 'pending'),
      progressPct: asInt(json['progress_pct']),
      currentStep: json['current_step'] as String? ?? '',
      currentSection: json['current_section'] as String?,
      sectionsDone: asInt(json['sections_done']),
      sectionsTotal: asInt(json['sections_total']),
      subAgents: agents,
    );
  }

  ResearchProgressModel copyWith({
    String? jobId,
    ResearchStatus? status,
    int? progressPct,
    String? currentStep,
    String? currentSection,
    int? sectionsDone,
    int? sectionsTotal,
    List<SubAgentStatusModel>? subAgents,
  }) {
    return ResearchProgressModel(
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

  ResearchProgress toEntity() {
    return ResearchProgress(
      jobId: jobId,
      status: status,
      progressPct: progressPct,
      currentStep: currentStep,
      currentSection: currentSection,
      sectionsDone: sectionsDone,
      sectionsTotal: sectionsTotal,
      subAgents: subAgents.map((a) => a.toEntity()).toList(),
    );
  }
}
