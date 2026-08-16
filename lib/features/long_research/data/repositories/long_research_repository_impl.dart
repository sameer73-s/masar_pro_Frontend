import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/research_job.dart';
import '../../domain/entities/research_progress.dart';
import '../../domain/enums/citation_style.dart';
import '../../domain/enums/research_language.dart';
import '../../domain/repositories/long_research_repository.dart';
import '../datasources/long_research_remote_datasource.dart';
import '../models/research_job_model.dart';

class LongResearchRepositoryImpl implements LongResearchRepository {
  final LongResearchRemoteDatasource remoteDatasource;

  static const _historyBoxName = 'research_history';
  static const _activeJobKey = 'active_job_id';
  static const _settingsBoxName = 'research_settings';

  LongResearchRepositoryImpl({required this.remoteDatasource});

  Future<Box<ResearchJobModel>> get _historyBox async {
    if (!Hive.isBoxOpen(_historyBoxName)) {
      return await Hive.openBox<ResearchJobModel>(_historyBoxName);
    }
    return Hive.box<ResearchJobModel>(_historyBoxName);
  }

  Future<Box<dynamic>> get _settingsBox async {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      return await Hive.openBox(_settingsBoxName);
    }
    return Hive.box(_settingsBoxName);
  }

  @override
  Future<Either<Failure, String>> startResearch({
    required String title,
    required int targetPages,
    required ResearchLanguage language,
    required CitationStyle citationStyle,
    required String subjectArea,
    String universityName = '',
    String supervisorName = '',
    String studentName = '',
    String academicSemester = '',
  }) async {
    try {
      final body = {
        'title': title,
        'target_pages': targetPages,
        'language': language.apiValue,
        'citation_style': citationStyle.apiValue,
        'subject_area': subjectArea,
        if (universityName.isNotEmpty) 'university_name': universityName,
        if (supervisorName.isNotEmpty) 'supervisor_name': supervisorName,
        if (studentName.isNotEmpty) 'student_name': studentName,
        if (academicSemester.isNotEmpty) 'academic_semester': academicSemester,
      };
      final jobId = await remoteDatasource.startResearch(body);
      await saveActiveJobId(jobId);
      return Right(jobId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<ResearchProgress> watchProgress(String jobId) {
    return remoteDatasource
        .watchProgress(jobId)
        .map((model) => model.toEntity());
  }

  @override
  Future<void> stopProgressWatch() {
    return remoteDatasource.closeProgressWatch(sendStop: true);
  }

  @override
  Future<void> closeProgressWatch() {
    return remoteDatasource.closeProgressWatch(sendStop: false);
  }

  @override
  Future<Either<Failure, String>> downloadResearch(String jobId) async {
    try {
      final bytes = await remoteDatasource.downloadResearch(jobId);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/research_$jobId.docx');
      await file.writeAsBytes(bytes);
      return Right(file.path);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<ResearchJob>> getLocalHistory() async {
    try {
      final box = await _historyBox;
      return box.values.map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveToHistory(ResearchJob job) async {
    final box = await _historyBox;
    final model = ResearchJobModel.fromEntity(job);
    await box.put(job.jobId, model);
  }

  @override
  Future<void> saveActiveJobId(String jobId) async {
    final box = await _settingsBox;
    await box.put(_activeJobKey, jobId);
  }

  @override
  Future<String?> getActiveJobId() async {
    final box = await _settingsBox;
    return box.get(_activeJobKey) as String?;
  }

  @override
  Future<void> clearActiveJobId() async {
    final box = await _settingsBox;
    await box.delete(_activeJobKey);
  }
}
