import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_dialog.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';
import 'package:masar_pro/core/presentation/widgets/pub/ai_worker_card.dart';
import 'package:masar_pro/core/presentation/widgets/pub/readiness_score_card.dart';

import '../../../../domain/entities/readiness_report.dart';
import '../../../../domain/enums/readiness_status.dart';
import '../../../bloc/publishing_bloc/publishing_bloc.dart';
import '../../../journal_matching/views/journal_matching_page.dart';

class ReadinessResultBody extends StatefulWidget {
  const ReadinessResultBody({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<ReadinessResultBody> createState() => _ReadinessResultBodyState();
}

class _ReadinessResultBodyState extends State<ReadinessResultBody> {
  ReadinessReport? _report;
  bool _journalsRequested = false;

  void _retryAnalysis() {
    context.read<PublishingBloc>().add(
          AnalyzeReadinessRequested(widget.projectId),
        );
  }

  void _onContinue(BuildContext context) {
    final bloc = context.read<PublishingBloc>();
    final alreadyDone = _journalsRequested ||
        bloc.state is PublishingJournalsMatched;

    if (!alreadyDone) {
      _journalsRequested = true;
      bloc.add(MatchJournalsRequested(widget.projectId));
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: JournalMatchingPage(projectId: widget.projectId),
        ),
      ),
    );
  }

  List<ReadinessCheck> _toChecks(ReadinessReport report) {
    return report.checks
        .map(
          (item) => ReadinessCheck(
            label: item.label.tr(),
            status: _toCheckStatus(item.status),
          ),
        )
        .toList();
  }

  ReadinessCheckStatus _toCheckStatus(ReadinessStatus status) {
    return switch (status) {
      ReadinessStatus.pass => ReadinessCheckStatus.ready,
      ReadinessStatus.warning => ReadinessCheckStatus.warning,
      ReadinessStatus.blocker => ReadinessCheckStatus.blocker,
    };
  }

  double _normalizedScore(double raw) {
    if (raw <= 1) return raw.clamp(0.0, 1.0);
    return (raw / 100).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublishingBloc, PublishingState>(
      listenWhen: (previous, current) =>
          current is PublishingReadinessAnalyzed ||
          (current is PublishingFailure && previous is! PublishingFailure),
      listener: (context, state) {
        if (state is PublishingReadinessAnalyzed) {
          _report = state.report;
          return;
        }
        if (state is! PublishingFailure) return;
        AppErrorDialog.show(
          context,
          message: state.error.tr(),
          okButtonText: 'retry'.tr(),
          onOk: _retryAnalysis,
        );
      },
      child: BlocBuilder<PublishingBloc, PublishingState>(
        builder: (context, state) {
          if (state is PublishingLoading && _report == null) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: AIWorkerCard(
                taskTitle: 'analyzingResearch'.tr(),
                progress: 0.62,
                state: AIWorkerState.processing,
              ),
            );
          }

          final report = state is PublishingReadinessAnalyzed
              ? state.report
              : _report;

          if (report != null) {
            return _ReadinessSuccessView(
              score: _normalizedScore(report.overallScore),
              checks: _toChecks(report),
              isContinuing: _journalsRequested && state is PublishingLoading,
              onContinue: () => _onContinue(context),
            );
          }

          if (state is PublishingFailure) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: AIWorkerCard(
              taskTitle: 'analyzingResearch'.tr(),
              progress: 0.62,
              state: AIWorkerState.processing,
            ),
          );
        },
      ),
    );
  }
}

class _ReadinessSuccessView extends StatelessWidget {
  const _ReadinessSuccessView({
    required this.score,
    required this.checks,
    required this.isContinuing,
    required this.onContinue,
  });

  final double score;
  final List<ReadinessCheck> checks;
  final bool isContinuing;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        ReadinessScoreCard(
          score: score,
          checks: checks,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'continueToJournalMatching'.tr(),
          onPressed: onContinue,
          isLoading: isContinuing,
          width: double.infinity,
          height: 52,
        ),
      ],
    );
  }
}
