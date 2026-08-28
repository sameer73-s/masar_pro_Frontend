import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/typography.dart';

import '../bloc/publishing_bloc/publishing_bloc.dart';
import 'widgets/ai_worker_card.dart';
import 'widgets/publishing_progress_header.dart';

class SubmissionMonitorBody extends StatefulWidget {
  const SubmissionMonitorBody({
    super.key,
    required this.projectId,
    required this.journalId,
    required this.targetUrl,
    required this.fileId,
    this.journalName,
  });

  final String projectId;
  final String journalId;
  final String targetUrl;
  final String fileId;
  final String? journalName;

  @override
  State<SubmissionMonitorBody> createState() => _SubmissionMonitorBodyState();
}

class _SubmissionMonitorBodyState extends State<SubmissionMonitorBody> {
  final List<_LiveLogEntry> _logs = [];
  String _state = 'QUEUED';
  String _message = 'Preparing the automation worker...';
  double _progress = 0;
  String? _jobId;
  String? _humanChallenge;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSubmission();
    });
  }

  void _startSubmission() {
    final bloc = context.read<PublishingBloc>();
    bloc.add(
      StartAutomatedSubmissionRequested(
        projectId: widget.projectId,
        journalId: widget.journalId,
        targetUrl: widget.targetUrl,
        fileId: widget.fileId,
      ),
    );
  }

  @override
  void dispose() {
    context.read<PublishingBloc>().add(
      const StopAutomatedSubmissionMonitoringRequested(),
    );
    super.dispose();
  }

  void _handleState(PublishingState state) {
    if (state is PublishingSubmissionStarted) {
      _jobId = state.job.jobId;
      _appendLog('QUEUED', 'Submission job created.');
      return;
    }
    if (state is SubmissionStepProgress) {
      _state = state.state;
      _message = state.message;
      _progress = state.progress;
      _humanChallenge = null;
      _appendLog(state.state, state.message);
      return;
    }
    if (state is HumanActionRequired) {
      _state = 'HUMAN_ACTION_REQUIRED';
      _message = 'Manual action is required to continue.';
      _humanChallenge = state.challengeType;
      _appendLog(_state, 'Human action required: ${state.challengeType}');
      return;
    }
    if (state is SubmissionCompleted) {
      _state = 'COMPLETED';
      _message = state.message;
      _progress = 1;
      _completed = true;
      _humanChallenge = null;
      _appendLog(_state, state.message);
      return;
    }
    if (state is PublishingFailure) {
      _state = 'FAILED';
      _message = state.error;
      _appendLog(_state, state.error);
    }
  }

  void _appendLog(String state, String message) {
    if (!mounted) return;
    setState(() {
      _logs.add(
        _LiveLogEntry(
          state: state,
          message: message,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublishingBloc, PublishingState>(
      listener: (context, state) => _handleState(state),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PublishingProgressHeader(
              progress: _progress,
              state: _state,
              message: _message,
              jobId: _jobId,
            ),
            const SizedBox(height: 16),
            AIWorkerCard(state: _state, message: _message),
            if (_humanChallenge != null) ...[
              const SizedBox(height: 14),
              _HumanActionBanner(challengeType: _humanChallenge!),
            ],
            if (_completed) ...[
              const SizedBox(height: 14),
              const _CompletedBanner(),
            ],
            const SizedBox(height: 20),
            Text(
              'Live Log Feed',
              style: AppTypography.bodyTitle(color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        'Waiting for worker events...',
                        style: AppTypography.body(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _logs.length,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _LogTile(entry: _logs[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveLogEntry {
  const _LiveLogEntry({
    required this.state,
    required this.message,
    required this.timestamp,
  });

  final String state;
  final String message;
  final DateTime timestamp;
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final _LiveLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final isAlert =
        entry.state == 'HUMAN_ACTION_REQUIRED' || entry.state == 'FAILED';
    final color = isAlert ? Colors.red : AppColors.accentPurple;
    final time =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isAlert ? Colors.red.withAlpha(12) : AppColors.surfacePurple,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? Colors.red.withAlpha(80) : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              isAlert ? Icons.warning_amber_rounded : Icons.circle,
              size: isAlert ? 19 : 10,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: AppTypography.body(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.state} · $time',
                  style: AppTypography.caption(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HumanActionBanner extends StatelessWidget {
  const _HumanActionBanner({required this.challengeType});

  final String challengeType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(100)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Human action required: $challengeType',
              style: AppTypography.body(color: Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(100)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dry run completed successfully. The form is ready for review.',
              style: AppTypography.body(color: Colors.green.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
