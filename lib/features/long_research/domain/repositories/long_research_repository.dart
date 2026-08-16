import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/research_job.dart';
import '../entities/research_progress.dart';
import '../enums/citation_style.dart';
import '../enums/research_language.dart';

abstract class LongResearchRepository {
  /// بدء بحث جديد → يعيد job_id
  Future<Either<Failure, String>> startResearch({
    required String title,
    required int targetPages,
    required ResearchLanguage language,
    required CitationStyle citationStyle,
    required String subjectArea,
    String universityName,
    String supervisorName,
    String studentName,
    String academicSemester,
  });

  /// WebSocket stream → تحديثات التقدم اللحظية
  Stream<ResearchProgress> watchProgress(String jobId);

  /// إرسال أمر الإيقاف عبر WebSocket وإغلاق الاتصال
  Future<void> stopProgressWatch();

  /// إغلاق اتصال التقدم دون إرسال stop (مثلاً بعد اكتمال المهمة)
  Future<void> closeProgressWatch();

  /// تحميل الملف → مسار محلي على الجهاز
  Future<Either<Failure, String>> downloadResearch(String jobId);

  /// تاريخ البحوث المنجزة (Hive محلي)
  Future<List<ResearchJob>> getLocalHistory();
  Future<void> saveToHistory(ResearchJob job);

  /// حفظ job_id النشط لاستعادته عند إعادة فتح التطبيق
  Future<void> saveActiveJobId(String jobId);
  Future<String?> getActiveJobId();
  Future<void> clearActiveJobId();
}
