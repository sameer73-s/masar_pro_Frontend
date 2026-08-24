import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/typography.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_dialog.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_widget.dart';
import 'package:masar_pro/core/presentation/widgets/loading_widget.dart';
import 'package:masar_pro/core/presentation/widgets/pub/add_project_button.dart';
import 'package:masar_pro/core/presentation/widgets/pub/empty_state.dart';
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
              return _PublishingProjectCard(project: project);
            },
          );
        }

        return const LoadingWidget();
      },
    );
  }
}

class _PublishingProjectCard extends StatelessWidget {
  const _PublishingProjectCard({required this.project});

  final ResearchProject project;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        UnifiedTaskCard(
          title: project.title,
          subtitle: _categoryFor(project.status),
          progress: _progressFor(project),
          taskType: UnifiedTaskType.publishing,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: _ProjectOverflowMenu(project: project),
        ),
      ],
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

class _ProjectOverflowMenu extends StatelessWidget {
  const _ProjectOverflowMenu({required this.project});

  final ResearchProject project;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<_ProjectMenuAction>(
        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
        padding: EdgeInsets.zero,
        onSelected: (action) => _handleAction(context, action),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _ProjectMenuAction.delete,
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, _ProjectMenuAction action) {
    switch (action) {
      case _ProjectMenuAction.delete:
        _confirmDelete(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    AppErrorDialog.show(
      context,
      title: 'Delete Project',
      message: 'This project will be permanently removed.',
      okButtonText: 'Delete',
      onOk: () => context.read<PublishingBloc>().add(
            DeletePublishingProjectRequested(project.id),
          ),
      secondaryButtonText: 'Cancel',
      onSecondaryAction: () {},
    );
  }
}

enum _ProjectMenuAction { delete }
