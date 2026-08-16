import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/typography.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_widget.dart';
import 'package:masar_pro/core/presentation/widgets/loading_widget.dart';
import 'package:masar_pro/core/presentation/widgets/pub/add_project_button.dart';
import 'package:masar_pro/core/presentation/widgets/pub/publishing_progress_header.dart';
import 'package:masar_pro/core/presentation/widgets/unified_task_card.dart';
import 'package:masar_pro/injection/injection_container.dart' as di;

import '../../../../domain/entities/research_project.dart';
import '../../../../domain/enums/research_project_status.dart';
import '../../../bloc/publishing_bloc/publishing_bloc.dart';
import '../../../upload_research/views/upload_research_page.dart';

class PubDashboardBody extends StatelessWidget {
  const PubDashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<PublishingBloc>()
        ..add(const FetchResearchProjectsRequested()),
      child: const _PubDashboardContent(),
    );
  }
}

class _PubDashboardContent extends StatelessWidget {
  const _PubDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AddProjectButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const UploadResearchPage(),
                ),
              );
              if (!context.mounted) return;
              context.read<PublishingBloc>().add(
                    const FetchResearchProjectsRequested(),
                  );
            },
          ),
          const SizedBox(height: 20),
          const PublishingProgressHeader(currentStage: 0),
          const SizedBox(height: 20),
          Text(
            'In progress',
            style: AppTypography.bodyTitle(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Expanded(child: _ProjectsList()),
        ],
      ),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  const _ProjectsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublishingBloc, PublishingState>(
      builder: (context, state) {
        if (state is PublishingLoading || state is PublishingInitial) {
          return const LoadingWidget();
        }

        if (state is PublishingFailure) {
          return AppErrorWidget(
            message: state.error,
            onRetry: () => context.read<PublishingBloc>().add(
                  const FetchResearchProjectsRequested(),
                ),
          );
        }

        if (state is PublishingProjectsLoaded) {
          if (state.projects.isEmpty) {
            return const EmptyState(
              message: 'No active publications yet. Start a new research!',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: state.projects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final project = state.projects[index];
              return UnifiedTaskCard(
                title: project.title,
                subtitle: _categoryFor(project.status),
                progress: _progressFor(project),
                taskType: UnifiedTaskType.publishing,
              );
            },
          );
        }

        return const LoadingWidget();
      },
    );
  }

  static String _categoryFor(ResearchProjectStatus status) {
    return switch (status) {
      ResearchProjectStatus.draft => 'Draft',
      ResearchProjectStatus.analyzing => 'Analyzing',
      ResearchProjectStatus.readyForJournal => 'Ready for journal',
      ResearchProjectStatus.needsRevision => 'Needs revision',
      ResearchProjectStatus.submitted => 'Submitted',
      ResearchProjectStatus.accepted => 'Accepted',
      ResearchProjectStatus.rejected => 'Rejected',
    };
  }

  static double _progressFor(ResearchProject project) {
    final score = project.readinessScore;
    if (score <= 1) return score.clamp(0.0, 1.0);
    return (score / 100).clamp(0.0, 1.0);
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfacePurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 36,
                color: AppColors.accentPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
