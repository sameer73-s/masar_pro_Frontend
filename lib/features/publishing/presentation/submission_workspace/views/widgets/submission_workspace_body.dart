import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';
import 'package:masar_pro/config/typography.dart';
import 'package:masar_pro/core/network/api_config.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_dialog.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_widget.dart';
import 'package:masar_pro/core/presentation/widgets/custom_text_field.dart';
import 'package:masar_pro/core/presentation/widgets/labeled_widget.dart';
import 'package:masar_pro/core/presentation/widgets/loading_widget.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';
import 'package:masar_pro/core/presentation/widgets/pub/submission_timeline_widget.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/entities/evidence.dart';
import '../../../../domain/entities/submission.dart';
import '../../../../domain/enums/submission_status.dart';
import '../../../bloc/publishing_bloc/publishing_bloc.dart';
import '../../../upload_research/views/widgets/manuscript_file_picker_button.dart';

const Color _kPubBorder = Color(0xFFE8E5F0);

class SubmissionWorkspaceBody extends StatefulWidget {
  const SubmissionWorkspaceBody({
    super.key,
    required this.projectId,
    required this.journalId,
    this.journalName,
  });

  final String projectId;
  final String journalId;
  final String? journalName;

  @override
  State<SubmissionWorkspaceBody> createState() =>
      _SubmissionWorkspaceBodyState();
}

class _SubmissionWorkspaceBodyState extends State<SubmissionWorkspaceBody> {
  final _formKey = GlobalKey<FormState>();
  final _submissionIdController = TextEditingController();
  final _trackingController = TextEditingController();

  String? _pickedEvidenceName;
  bool _isOpeningFile = false;

  @override
  void initState() {
    super.initState();
    context.read<PublishingBloc>().add(
          FetchSubmissionRequested(widget.projectId),
        );
  }

  @override
  void dispose() {
    _submissionIdController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<PublishingBloc>().add(
          FetchSubmissionRequested(widget.projectId),
        );
  }

  void _createSubmission() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final journalId = widget.journalId.trim();
    if (journalId.isEmpty) {
      AppErrorDialog.show(
        context,
        message: 'journalMustBeSelected'.tr(),
      );
      return;
    }

    context.read<PublishingBloc>().add(
          CreateSubmissionRequested(
            widget.projectId,
            journalId,
            _submissionIdController.text.trim(),
          ),
        );
  }

  Future<void> _pickAndUploadEvidence(String submissionId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    final path = picked.path;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      await AppErrorDialog.show(
        context,
        message: 'couldNotReadSelectedFile'.tr(),
      );
      return;
    }

    setState(() => _pickedEvidenceName = picked.name);
    if (!mounted) return;
    context.read<PublishingBloc>().add(
          AddEvidenceRequested(submissionId, File(path)),
        );
  }

  Future<void> _viewEvidence(Evidence evidence) async {
    final url = _absoluteUrl(evidence.downloadUrl);
    if (url == null) {
      await AppErrorDialog.show(
        context,
        message: 'noDownloadUrlAvailable'.tr(),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      await AppErrorDialog.show(context, message: 'invalidFileUrl'.tr());
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      await AppErrorDialog.show(context, message: 'couldNotOpenFile'.tr());
    }
  }

  Future<void> _downloadEvidence(Evidence evidence) async {
    if (_isOpeningFile) return;

    final url = _absoluteUrl(evidence.downloadUrl);
    if (url == null) {
      await AppErrorDialog.show(
        context,
        message: 'noDownloadUrlAvailable'.tr(),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      await AppErrorDialog.show(context, message: 'invalidFileUrl'.tr());
      return;
    }

    setState(() => _isOpeningFile = true);
    try {
      final dir = await getTemporaryDirectory();
      final fileName = _fileNameFromEvidence(evidence, uri);
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
              : 'couldNotOpenFile'.tr(),
        );
      }
    } catch (_) {
      if (mounted) {
        await AppErrorDialog.show(context, message: 'downloadFailed'.tr());
      }
    } finally {
      if (mounted) setState(() => _isOpeningFile = false);
    }
  }

  static String? _absoluteUrl(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http')) return value;
    return '${ApiConfig.normalizedBaseUrl}$value';
  }

  static String _fileNameFromEvidence(Evidence evidence, Uri uri) {
    final last = uri.pathSegments.isNotEmpty
        ? Uri.decodeComponent(uri.pathSegments.last)
        : evidence.displayName;
    final cleaned = last.split('?').first.trim();
    if (cleaned.isEmpty || !cleaned.contains('.')) {
      return evidence.displayName.replaceAll(RegExp(r'[^\w.\-]+'), '_');
    }
    return cleaned.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublishingBloc, PublishingState>(
      listenWhen: (previous, current) =>
          current is PublishingFailure ||
          current is PublishingSubmissionLoaded,
      listener: (context, state) {
        if (state is PublishingFailure) {
          AppErrorDialog.show(context, message: state.error.tr());
        } else if (state is PublishingSubmissionLoaded) {
          _trackingController.text = state.submission.submissionId;
        }
      },
      child: BlocBuilder<PublishingBloc, PublishingState>(
        builder: (context, state) {
          if (state is PublishingSubmissionLoaded) {
            return _LoadedWorkspace(
              submission: state.submission,
              evidence: state.evidence,
              journalName: widget.journalName,
              trackingController: _trackingController,
              pickedEvidenceName: _pickedEvidenceName,
              onUploadEvidence: () =>
                  _pickAndUploadEvidence(state.submission.id),
              onViewEvidence: _viewEvidence,
              onDownloadEvidence: _downloadEvidence,
            );
          }

          if (state is PublishingLoading || state is PublishingInitial) {
            return const LoadingWidget();
          }

          if (state is PublishingFailure) {
            return AppErrorWidget(
              message: state.error.tr(),
              onRetry: _fetch,
            );
          }

          return _CreateSubmissionForm(
            formKey: _formKey,
            controller: _submissionIdController,
            journalName: widget.journalName,
            onSubmit: _createSubmission,
          );
        },
      ),
    );
  }
}

class _CreateSubmissionForm extends StatelessWidget {
  const _CreateSubmissionForm({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
    this.journalName,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String? journalName;

  @override
  Widget build(BuildContext context) {
    final journal = journalName?.trim();

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'noSubmissionRecordedYet'.tr(),
            style: AppTypography.bodyTitle(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'enterJournalSubmissionIdHint'.tr(),
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          if (journal != null && journal.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              journal,
              style: AppTypography.body(color: AppColors.accentPurple),
            ),
          ],
          const SizedBox(height: 24),
          LabeledWidget(
            labelPadding: const EdgeInsets.only(bottom: 8),
            label: Text(
              'journalSubmissionId'.tr(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            widget: CustomTextField(
              controller: controller,
              hintText: 'journalSubmissionIdExample',
              validationMessage: 'pleaseEnterJournalSubmissionId'.tr(),
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'createSubmission'.tr(),
            onPressed: onSubmit,
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}

class _LoadedWorkspace extends StatelessWidget {
  const _LoadedWorkspace({
    required this.submission,
    required this.evidence,
    required this.trackingController,
    required this.onUploadEvidence,
    required this.onViewEvidence,
    required this.onDownloadEvidence,
    this.journalName,
    this.pickedEvidenceName,
  });

  final Submission submission;
  final List<Evidence> evidence;
  final TextEditingController trackingController;
  final VoidCallback onUploadEvidence;
  final ValueChanged<Evidence> onViewEvidence;
  final ValueChanged<Evidence> onDownloadEvidence;
  final String? journalName;
  final String? pickedEvidenceName;

  @override
  Widget build(BuildContext context) {
    final journal = journalName?.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          'submissionStatus'.tr(),
          style: AppTypography.bodyTitle(color: AppColors.primary),
        ),
        if (journal != null && journal.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            journal,
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 12),
        SubmissionTimelineWidget(
          events: _timelineEvents(submission),
        ),
        const SizedBox(height: 24),
        LabeledWidget(
          labelPadding: const EdgeInsets.only(bottom: 8),
          label: Text(
            'trackingNumber'.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          widget: CustomTextField(
            controller: trackingController,
            hintText: 'trackingNumber',
            readOnly: true,
          ),
        ),
        const SizedBox(height: 24),
        LabeledWidget(
          labelPadding: const EdgeInsets.only(bottom: 8),
          label: Text(
            'uploadEvidence'.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          widget: ManuscriptFilePickerButton(
            fileName: pickedEvidenceName,
            onPressed: onUploadEvidence,
            emptyTitle: 'selectImageOrPdf',
            emptySubtitle: 'screenshotOrEmailConfirmation',
            selectedSubtitle: 'tapToUploadAnotherFile',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'uploadedEvidence'.tr(),
          style: AppTypography.bodyTitle(color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        if (evidence.isEmpty)
          Text(
            'noEvidenceUploadedYet'.tr(),
            style: AppTypography.body(color: AppColors.textSecondary),
          )
        else
          ...evidence.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EvidenceTile(
                evidence: item,
                onView: () => onViewEvidence(item),
                onDownload: () => onDownloadEvidence(item),
              ),
            ),
          ),
      ],
    );
  }

  static List<TimelineEvent> _timelineEvents(Submission submission) {
    final stages = submission.status == SubmissionStatus.rejected
        ? const [
            SubmissionStatus.submitted,
            SubmissionStatus.rejected,
          ]
        : const [
            SubmissionStatus.submitted,
            SubmissionStatus.withEditor,
            SubmissionStatus.underReview,
            SubmissionStatus.revisionRequired,
            SubmissionStatus.resubmitted,
            SubmissionStatus.accepted,
          ];

    final currentIndex = stages.indexOf(submission.status);
    final resolvedIndex = currentIndex < 0 ? 0 : currentIndex;

    return [
      for (var i = 0; i < stages.length; i++)
        TimelineEvent(
          title: stages[i].label,
          timestamp: i == 0
              ? _formatTimestamp(submission.submittedAt)
              : i == resolvedIndex
                  ? _formatTimestamp(submission.updatedAt)
                  : i < resolvedIndex
                      ? 'completed'.tr()
                      : 'pending'.tr(),
          state: i < resolvedIndex
              ? TimelineEventState.completed
              : i == resolvedIndex
                  ? TimelineEventState.current
                  : TimelineEventState.pending,
        ),
    ];
  }

  static String _formatTimestamp(DateTime value) {
    const months = [
      'monthJan',
      'monthFeb',
      'monthMar',
      'monthApr',
      'monthMayShort',
      'monthJun',
      'monthJul',
      'monthAug',
      'monthSep',
      'monthOct',
      'monthNov',
      'monthDec',
    ];
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1].tr()} ${local.year} · $hour:$minute';
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({
    required this.evidence,
    required this.onView,
    required this.onDownload,
  });

  final Evidence evidence;
  final VoidCallback onView;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final isPdf = evidence.fileType.toUpperCase().contains('PDF') ||
        evidence.displayName.toLowerCase().endsWith('.pdf');

    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        side: const BorderSide(color: _kPubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
              color: AppColors.accentPurple,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evidence.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    evidence.fileType.replaceAll('_', ' '),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'view'.tr(),
              onPressed: onView,
              icon: const Icon(
                Icons.visibility_outlined,
                color: AppColors.accentPurple,
              ),
            ),
            IconButton(
              tooltip: 'download'.tr(),
              onPressed: onDownload,
              icon: const Icon(
                Icons.download_rounded,
                color: AppColors.accentPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
