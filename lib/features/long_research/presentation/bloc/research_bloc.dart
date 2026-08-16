import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/research_job.dart';
import '../../domain/entities/research_progress.dart';
import '../../domain/enums/research_status.dart';
import '../../domain/repositories/long_research_repository.dart';
import 'research_event.dart';
import 'research_state.dart';

class ResearchBloc extends Bloc<ResearchEvent, ResearchState> {
  final LongResearchRepository repository;

  StreamSubscription<ResearchProgress>? _progressSubscription;
  ResearchProgress? _lastProgress;
  String? _currentJobId;

  ResearchBloc({required this.repository}) : super(ResearchInitial()) {
    on<LoadResearchHistoryEvent>(_onLoadHistory);
    on<StartResearchEvent>(_onStartResearch);
    on<ProgressUpdatedEvent>(_onProgressUpdated);
    on<DownloadResearchEvent>(_onDownload);
    on<ReconnectResearchEvent>(_onReconnect);
    on<ResetResearchEvent>(_onReset);
    on<CloseProgressWatchEvent>(_onCloseProgressWatch);
  }

  Future<void> _onLoadHistory(
      LoadResearchHistoryEvent event, Emitter<ResearchState> emit) async {
    final history = await repository.getLocalHistory();
    emit(ResearchFormReady(history: history));
  }

  Future<void> _onStartResearch(
      StartResearchEvent event, Emitter<ResearchState> emit) async {
    emit(ResearchStarting());
    await _cancelProgressSubscription(sendStop: true);

    final result = await repository.startResearch(
      title: event.title,
      targetPages: event.targetPages,
      language: event.language,
      citationStyle: event.citationStyle,
      subjectArea: event.subjectArea,
      universityName: event.universityName,
      supervisorName: event.supervisorName,
      studentName: event.studentName,
      academicSemester: event.academicSemester,
    );

    result.fold(
      (failure) => emit(ResearchFailed(message: failure.message)),
      (jobId) {
        _currentJobId = jobId;
        _subscribeToProgress(jobId);
      },
    );
  }

  void _subscribeToProgress(String jobId) {
    _progressSubscription =
        repository.watchProgress(jobId).listen(
      (progress) {
        add(ProgressUpdatedEvent(progress));
      },
      onError: (e) {
        add(ProgressUpdatedEvent(ResearchProgress(
          jobId: jobId,
          status: ResearchStatus.failed,
          progressPct: _lastProgress?.progressPct ?? 0,
          currentStep: 'انقطع الاتصال',
          sectionsDone: _lastProgress?.sectionsDone ?? 0,
          sectionsTotal: _lastProgress?.sectionsTotal ?? 0,
          subAgents: _lastProgress?.subAgents ?? const [],
        )));
      },
    );
  }

  Future<void> _onProgressUpdated(
      ProgressUpdatedEvent event, Emitter<ResearchState> emit) async {
    _lastProgress = event.progress;

    if (event.progress.status == ResearchStatus.failed ||
        event.progress.status == ResearchStatus.cancelled) {
      await _cancelProgressSubscription();
      await repository.clearActiveJobId();
      emit(ResearchFailed(
        message: event.progress.currentStep.isNotEmpty
            ? event.progress.currentStep
            : (event.progress.status == ResearchStatus.cancelled
                ? 'تم إيقاف البحث'
                : 'فشل إنشاء البحث'),
        jobId: event.progress.jobId,
      ));
      return;
    }

    if (event.progress.status == ResearchStatus.completed) {
      emit(ResearchInProgress(event.progress));
      await Future.delayed(const Duration(seconds: 1));

      // Save to history
      final job = ResearchJob(
        jobId: event.progress.jobId,
        title: _currentJobId ?? event.progress.jobId,
        status: ResearchStatus.completed,
        downloadUrl: '',
        totalWords: 0,
        sourcesCount: 0,
        processingTimeSeconds: 0,
        createdAt: DateTime.now(),
      );
      await repository.saveToHistory(job);
      await repository.clearActiveJobId();
      await _cancelProgressSubscription();
      return;
    }

    emit(ResearchInProgress(event.progress));
  }

  Future<void> _onDownload(
      DownloadResearchEvent event, Emitter<ResearchState> emit) async {
    final currentProgress = _lastProgress;
    if (currentProgress == null) return;

    emit(ResearchDownloading(currentProgress));

    final result = await repository.downloadResearch(event.jobId);
    result.fold(
      (failure) => emit(ResearchFailed(message: failure.message)),
      (filePath) => emit(ResearchDownloadReady(
        localFilePath: filePath,
        finalProgress: currentProgress,
      )),
    );
  }

  Future<void> _onReconnect(
      ReconnectResearchEvent event, Emitter<ResearchState> emit) async {
    await _cancelProgressSubscription();
    _currentJobId = event.jobId;
    _subscribeToProgress(event.jobId);
  }

  Future<void> _onReset(
      ResetResearchEvent event, Emitter<ResearchState> emit) async {
    await _cancelProgressSubscription(sendStop: true);
    _lastProgress = null;
    _currentJobId = null;
    final history = await repository.getLocalHistory();
    emit(ResearchFormReady(history: history));
  }

  Future<void> _onCloseProgressWatch(
      CloseProgressWatchEvent event, Emitter<ResearchState> emit) async {
    await _cancelProgressSubscription(sendStop: true);
  }

  Future<void> _cancelProgressSubscription({bool sendStop = false}) async {
    // Stop/close the socket before cancelling the subscription so the sink
    // is still available when the user leaves or resets.
    try {
      if (sendStop) {
        await repository.stopProgressWatch();
      } else {
        await repository.closeProgressWatch();
      }
    } catch (_) {}
    await _progressSubscription?.cancel();
    _progressSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelProgressSubscription(sendStop: true);
    return super.close();
  }
}
