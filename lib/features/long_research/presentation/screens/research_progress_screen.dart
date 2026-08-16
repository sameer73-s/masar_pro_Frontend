import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/widgets/app_success_dialog.dart';
import '../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../domain/enums/research_status.dart';
import '../bloc/research_bloc.dart';
import '../bloc/research_event.dart';
import '../bloc/research_state.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/parallel_workers_tracker.dart';
import '../widgets/pipeline_stage_tracker.dart';
import '../widgets/research_complete_card.dart';
import '../../domain/entities/research_progress.dart';
import '../../domain/entities/sub_agent_status.dart';

/// الرسائل التشجيعية حسب حالة البحث
const _messages = {
  ResearchStatus.outlining: [
    'جاري تحليل عنوان بحثك...',
    'نبني هيكل أكاديمي احترافي...',
    'نحدد الفصول والمباحث الأنسب...',
  ],
  ResearchStatus.researching: [
    'نبحث في Google Scholar...',
    'نجمع أبحاثاً حقيقية من قواعد البيانات...',
    'نحدد المصادر الأكثر صلة بموضوعك...',
    'نسجل أسماء المؤلفين والمجلات...',
  ],
  ResearchStatus.writing: [
    'Gemini يكتب مبحثاً مبحثاً...',
    'كل فصل يقرأ السابق ويكمل الفكرة...',
    'الكتابة المجزأة تضمن جودة لا مثيل لها...',
    'نوثق كل فقرة بأسلوب APA...',
  ],
  ResearchStatus.reviewing: [
    'نتأكد من ترابط الأفكار بين الفصول...',
    'نكتب الملخص العلمي بعد اكتمال البحث...',
    'نضيف الانتقالات الطبيعية بين المباحث...',
  ],
  ResearchStatus.assembling: [
    'نُجمّع كل شيء في ملف Word احترافي...',
    'نضبط التنسيق الأكاديمي RTL...',
    'نرتب قائمة المراجع بنظام APA...',
    'نُضيف صفحة الغلاف وفهرس المحتويات...',
  ],
};

/// شاشة تقدم البحث
class ResearchProgressScreen extends StatefulWidget {
  const ResearchProgressScreen({super.key});

  @override
  State<ResearchProgressScreen> createState() =>
      _ResearchProgressScreenState();
}

class _ResearchProgressScreenState
    extends State<ResearchProgressScreen> {
  Timer? _messageTimer;
  int _messageIndex = 0;
  ResearchStatus _lastStatus = ResearchStatus.pending;
  Timer? _longWaitTimer;
  bool _showLongWaitSnack = false;
  ResearchBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ResearchBloc>();
    _startMessageRotation(ResearchStatus.outlining);
    _startLongWaitTimer();
  }

  void _startMessageRotation(ResearchStatus status) {
    if (status == _lastStatus) return;
    _lastStatus = status;
    _messageIndex = 0;
    _messageTimer?.cancel();

    final msgs = _messages[status];
    if (msgs == null || msgs.isEmpty) return;

    _messageTimer =
        Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % msgs.length;
        });
      }
    });
  }

  void _startLongWaitTimer() {
    _longWaitTimer =
        Timer(const Duration(minutes: 5), () {
      if (mounted && !_showLongWaitSnack) {
        _showLongWaitSnack = true;
        AppSuccessDialog.show(
          context,
          message:
              'البحث يسير بشكل طبيعي — يمكنك إبقاء التطبيق مفتوحاً',
        );
      }
    });
  }

  String _currentMessage(ResearchStatus status) {
    final msgs =
        _messages[status] ?? ['جاري إعداد بحثك...'];
    if (_messageIndex >= msgs.length) return msgs.first;
    return msgs[_messageIndex];
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _longWaitTimer?.cancel();
    // Close the progress WebSocket when leaving this screen (idempotent).
    final bloc = _bloc;
    if (bloc != null && !bloc.isClosed) {
      bloc.add(CloseProgressWatchEvent());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResearchBloc, ResearchState>(
      listener: (context, state) {
        if (state is ResearchInProgress) {
          _startMessageRotation(state.progress.status);
        }
        if (state is ResearchDownloadReady) {
          _handleDownloadReady(state.localFilePath);
        }
      },
      builder: (context, state) {
        final bool isCompleted = state is ResearchDownloadReady;

        return PopScope(
          canPop: isCompleted || state is ResearchFailed,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: kBgLight,
              appBar: CustomAppBar(
                title: isCompleted
                    ? '✓ اكتمل البحث'
                    : 'جاري إعداد بحثك...',
                showBackButton: isCompleted || state is ResearchFailed,
              ),
              body: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ResearchState state) {
    // ──── فشل ────
    if (state is ResearchFailed) {
      return _FailureView(
        message: state.message,
        jobId: state.jobId,
        onRetry: state.jobId != null
            ? () => context
                .read<ResearchBloc>()
                .add(ReconnectResearchEvent(state.jobId!))
            : null,
        onReset: () {
          context.read<ResearchBloc>().add(ResetResearchEvent());
          Navigator.of(context).pop();
        },
      );
    }

    // ──── اكتمل + تحميل جاهز ────
    if (state is ResearchDownloadReady) {
      return SingleChildScrollView(
        padding: pagePadding,
        child: ResearchCompleteCard(
          totalWords: state.finalProgress.sectionsTotal * 280,
          sourcesCount: state.finalProgress.sectionsTotal * 3,
          processingTimeSeconds: 0,
          isDownloading: false,
          onDownload: () => _handleDownloadReady(state.localFilePath),
          onNewResearch: () {
            context.read<ResearchBloc>().add(ResetResearchEvent());
            Navigator.of(context).pop();
          },
        ),
      );
    }

    // ──── تحميل جارٍ ────
    if (state is ResearchDownloading) {
      return _ProgressContent(
        progress: state.progress,
        currentMessage: _currentMessage(state.progress.status),
        isDownloading: true,
        onDownload: null,
        onNewResearch: null,
      );
    }

    // ──── في التقدم ────
    if (state is ResearchInProgress) {
      final isComplete =
          state.progress.status == ResearchStatus.completed;
      return _ProgressContent(
        progress: state.progress,
        currentMessage: isComplete
            ? 'اكتمل البحث! جاري التحضير...'
            : _currentMessage(state.progress.status),
        isDownloading: false,
        onDownload: isComplete
            ? () => context.read<ResearchBloc>().add(
                  DownloadResearchEvent(state.progress.jobId),
                )
            : null,
        onNewResearch: null,
      );
    }

    // ──── بدء (loading) ────
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: kGoldAccent),
          SizedBox(height: 16),
          Text(
            'جاري بدء البحث...',
            style: TextStyle(color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  void _handleDownloadReady(String filePath) {
    AppSuccessDialog.show(
      context,
      message: 'تم حفظ الملف: $filePath',
    );
  }
}

// ─── محتوى التقدم ─────────────────────────────────────────────────────────

class _ProgressContent extends StatelessWidget {
  final ResearchProgress progress;
  final String currentMessage;
  final bool isDownloading;
  final VoidCallback? onDownload;
  final VoidCallback? onNewResearch;

  const _ProgressContent({
    required this.progress,
    required this.currentMessage,
    required this.isDownloading,
    this.onDownload,
    this.onNewResearch,
  });

  @override
  Widget build(BuildContext context) {
    final pct = progress.progressPct;
    final status = progress.status;
    final isComplete = status == ResearchStatus.completed;
    final List<SubAgentStatus> workers = progress.subAgents;

    return SingleChildScrollView(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // ① دائرة التقدم
          AnimatedProgressRing(
            progress: pct / 100,
            isCompleted: isComplete,
            subLabel: progress.currentSection ??
                (pct < 100 ? status.label : null),
          ),
          const SizedBox(height: 24),

          // ② رسالة متحركة
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              currentMessage,
              key: ValueKey(currentMessage),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: kTextSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ③ مرحلة الكتابة — بطاقة القسم الحالي
          if (status == ResearchStatus.writing &&
              progress.currentSection != null)
            _CurrentSectionCard(
              section: progress.currentSection!,
              done: progress.sectionsDone,
              total: progress.sectionsTotal,
            ),
          if (status == ResearchStatus.writing)
            const SizedBox(height: 16),

          // ④ pipeline stages
          PipelineStageTracker(currentStatus: status),
          const SizedBox(height: 16),

          // ⑤ parallel research workers (hidden when empty)
          ParallelWorkersTracker(workers: workers),
          if (workers.isNotEmpty) const SizedBox(height: 24) else const SizedBox(height: 8),

          // ⑥ زر تحميل إذا اكتمل
          if (onDownload != null)
            PrimaryButton(
              text: 'تحميل ملف Word',
              onPressed: isDownloading ? null : onDownload,
              isLoading: isDownloading,
              icon: Icons.download_rounded,
              width: double.infinity,
              height: 52,
            ),
        ],
      ),
    );
  }
}

// ─── بطاقة القسم الجاري كتابته ────────────────────────────────────────────

class _CurrentSectionCard extends StatelessWidget {
  final String section;
  final int done;
  final int total;

  const _CurrentSectionCard({
    required this.section,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Container(
        key: ValueKey(section),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kResearchBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: kGoldAccent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            const Text(
              'يُكتب الآن:',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 11,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              section,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: total > 0 ? done / total : 0,
                color: kGoldAccent,
                backgroundColor: kBorderColor,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 4),
              Text(
                '$done / $total فصل',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 11,
                  color: kTextSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── عرض الفشل ────────────────────────────────────────────────────────────

class _FailureView extends StatelessWidget {
  final String message;
  final String? jobId;
  final VoidCallback? onRetry;
  final VoidCallback onReset;

  const _FailureView({
    required this.message,
    this.jobId,
    this.onRetry,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😞',
                style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ أثناء إنشاء البحث',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSecondary),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              PrimaryButton(
                text: 'إعادة الاتصال',
                onPressed: onRetry,
                icon: Icons.refresh,
                width: double.infinity,
                height: 48,
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(kButtonRadius),
                  ),
                ),
                child: const Text(
                  'العودة إلى البداية',
                  style: TextStyle(color: kTextSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
