import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../config/app_theme.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/presentation/widgets/academic_journey_header.dart';
import '../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../core/presentation/widgets/app_success_dialog.dart';
import '../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../../core/presentation/widgets/pub/ai_worker_card.dart';
import '../../../../../core/presentation/widgets/status_badge.dart';
import '../../../domain/entities/academic_project.dart';
import '../../bloc/academic_workspace_bloc/academic_workspace_bloc.dart';
import '../../widgets/feedback_bottom_sheet.dart';
import '../pages/academic_project_placeholder_page.dart';

class AcademicProjectCard extends StatefulWidget {
  const AcademicProjectCard({super.key, required this.project});

  final AcademicProject project;

  @override
  State<AcademicProjectCard> createState() => _AcademicProjectCardState();
}

class _AcademicProjectCardState extends State<AcademicProjectCard> {
  bool _awaitingFeedback = false;
  bool _isDownloading = false;

  Future<void> _downloadAndOpenRevisedFile(String fileUrl) async {
    if (_isDownloading) return;

    final url = fileUrl.startsWith('http')
        ? fileUrl
        : '${ApiConfig.normalizedBaseUrl}$fileUrl';
    final uri = Uri.tryParse(url);
    if (uri == null) {
      await AppErrorDialog.show(context, message: 'Invalid revised file URL');
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final dir = await getTemporaryDirectory();
      final fileName = _fileNameFromUri(uri);
      final savePath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      await dio.download(url, savePath);

      final openResult = await OpenFilex.open(savePath);
      if (!mounted) return;
      if (openResult.type != ResultType.done) {
        await AppErrorDialog.show(
          context,
          message: openResult.message.isNotEmpty
              ? openResult.message
              : 'Could not open the revised file',
        );
      }
    } catch (_) {
      if (mounted) {
        await AppErrorDialog.show(context, message: 'Download failed');
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  static String _fileNameFromUri(Uri uri) {
    final last = uri.pathSegments.isNotEmpty
        ? Uri.decodeComponent(uri.pathSegments.last)
        : '';
    final cleaned = last.split('?').first.trim();
    if (cleaned.isEmpty || !cleaned.contains('.')) {
      return 'academic_revision.docx';
    }
    return cleaned.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  }

  void _openFeedbackSheet() {
    FeedbackBottomSheet.show(
      context,
      feedbackSource: FeedbackSource.doctor,
      onSubmit: (feedbackText, feedbackFile, instructions) {
        setState(() => _awaitingFeedback = true);
        context.read<AcademicWorkspaceBloc>().add(
              SubmitFeedbackRequested(
                projectId: widget.project.id,
                feedbackText: feedbackText,
                instructions: instructions,
                source: 'doctor',
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AcademicWorkspaceBloc, AcademicWorkspaceState>(
      listenWhen: (previous, current) =>
          _awaitingFeedback &&
          (current is FeedbackProcessed || current is AcademicWorkspaceFailure),
      listener: (context, state) {
        if (state is FeedbackProcessed) {
          setState(() => _awaitingFeedback = false);
          AppSuccessDialog.show(
            context,
            title: 'Revision Ready',
            message: 'Your AI-revised document is ready to download.',
            okButtonText: 'Download Revised File',
            onOk: () => _downloadAndOpenRevisedFile(state.fileUrl),
          );
        } else if (state is AcademicWorkspaceFailure) {
          setState(() => _awaitingFeedback = false);
        }
      },
      buildWhen: (previous, current) =>
          current is AcademicWorkspaceLoading ||
          current is FeedbackProcessed ||
          current is AcademicWorkspaceFailure ||
          current is AcademicProjectsLoaded,
      builder: (context, state) {
        final showWorker =
            _awaitingFeedback && state is AcademicWorkspaceLoading;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.project.title,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    status: Status.toDo,
                    label: widget.project.academicLevel,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AcademicJourneyHeader(
                proposalStatus: widget.project.proposalStatus,
                researchStatus: widget.project.researchStatus,
                publishingStatus: widget.project.publishingStatus,
              ),
              const SizedBox(height: 16),
              if (showWorker) ...[
                const AIWorkerCard(
                  taskTitle: 'Generating AI Revision',
                  progress: 0.55,
                  state: AIWorkerState.processing,
                ),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                text: 'View Project',
                onPressed: showWorker
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AcademicProjectPlaceholderPage(
                              projectId: widget.project.id,
                              projectTitle: widget.project.title,
                            ),
                          ),
                        );
                      },
                width: double.infinity,
                height: 42,
                borderRadius: 10,
                backgroundColor: AppColors.surfacePurple,
                textColor: AppColors.accentPurple,
              ),
              // Temporary entry point — move to Proposal/Research detail pages later.
              const SizedBox(height: 10),
              PrimaryButton(
                text: 'Add Feedback',
                onPressed: showWorker || _isDownloading ? null : _openFeedbackSheet,
                width: double.infinity,
                height: 42,
                borderRadius: 10,
                icon: Icons.rate_review_outlined,
              ),
            ],
          ),
        );
      },
    );
  }
}
