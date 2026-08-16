import '../../domain/entities/research_progress.dart';
import '../../domain/enums/citation_style.dart';
import '../../domain/enums/research_language.dart';

abstract class ResearchEvent {}

/// يُطلَق عند الضغط على "ابدأ البحث"
class StartResearchEvent extends ResearchEvent {
  final String title;
  final int targetPages;
  final ResearchLanguage language;
  final CitationStyle citationStyle;
  final String subjectArea;
  final String universityName;
  final String supervisorName;
  final String studentName;
  final String academicSemester;

  StartResearchEvent({
    required this.title,
    required this.targetPages,
    required this.language,
    required this.citationStyle,
    required this.subjectArea,
    this.universityName = '',
    this.supervisorName = '',
    this.studentName = '',
    this.academicSemester = '',
  });
}

/// يُطلَق تلقائياً عند وصول تحديث من WebSocket
class ProgressUpdatedEvent extends ResearchEvent {
  final ResearchProgress progress;
  ProgressUpdatedEvent(this.progress);
}

/// يُطلَق عند الضغط على "تحميل"
class DownloadResearchEvent extends ResearchEvent {
  final String jobId;
  DownloadResearchEvent(this.jobId);
}

/// يُطلَق عند محاولة إعادة الاتصال بعد انقطاع
class ReconnectResearchEvent extends ResearchEvent {
  final String jobId;
  ReconnectResearchEvent(this.jobId);
}

/// تحميل تاريخ البحوث المحلي
class LoadResearchHistoryEvent extends ResearchEvent {}

/// إعادة تعيين الحالة
class ResetResearchEvent extends ResearchEvent {}

/// إغلاق WebSocket التقدم عند مغادرة شاشة التقدم (بدون reset كامل)
class CloseProgressWatchEvent extends ResearchEvent {}
