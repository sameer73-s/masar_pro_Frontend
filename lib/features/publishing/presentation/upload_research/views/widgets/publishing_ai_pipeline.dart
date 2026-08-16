import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/typography.dart';
import 'package:masar_pro/core/presentation/widgets/pub/ai_worker_card.dart';

import '../../../bloc/publishing_bloc/publishing_bloc.dart';

class PublishingAiPipeline extends StatelessWidget {
  const PublishingAiPipeline({
    super.key,
    required this.state,
  });

  final PublishingState state;

  static const _steps = [
    'Creating research project',
    'Uploading manuscript',
    'Analyzing readiness',
  ];

  int get _activeIndex {
    if (state is PublishingManuscriptUploaded) return 2;
    if (state is PublishingResearchCreated) return 1;
    if (state is PublishingLoading) {
      final message = (state as PublishingLoading).message ?? '';
      if (message.toLowerCase().contains('analyz')) return 2;
      if (message.toLowerCase().contains('upload')) return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex;
    final statusMessage = state is PublishingLoading
        ? (state as PublishingLoading).message
        : _steps[activeIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            statusMessage ?? 'Working...',
            style: AppTypography.bodyTitle(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          const Text(
            'AI workers are processing your submission.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < _steps.length; i++) ...[
            AIWorkerCard(
              taskTitle: _steps[i],
              progress: i == activeIndex ? 0.62 : 0,
              state: i < activeIndex
                  ? AIWorkerState.completed
                  : i == activeIndex
                      ? AIWorkerState.processing
                      : AIWorkerState.waiting,
            ),
            if (i < _steps.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
