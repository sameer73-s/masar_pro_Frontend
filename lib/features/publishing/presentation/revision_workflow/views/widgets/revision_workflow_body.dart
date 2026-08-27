import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_dialog.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_widget.dart';
import 'package:masar_pro/core/presentation/widgets/app_success_dialog.dart';
import 'package:masar_pro/core/presentation/widgets/custom_text_field.dart';
import 'package:masar_pro/core/presentation/widgets/labeled_widget.dart';
import 'package:masar_pro/core/presentation/widgets/loading_widget.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';
import 'package:masar_pro/core/presentation/widgets/pub/empty_state.dart';
import 'package:masar_pro/core/presentation/widgets/pub/reviewer_comment_card.dart';
import 'package:masar_pro/core/presentation/widgets/small_pill_button.dart';

import '../../../../domain/entities/response_item.dart';
import '../../../../domain/entities/reviewer_comment.dart';
import '../../../bloc/publishing_bloc/publishing_bloc.dart';

class RevisionWorkflowBody extends StatefulWidget {
  const RevisionWorkflowBody({
    super.key,
    required this.submissionId,
  });

  final String submissionId;

  @override
  State<RevisionWorkflowBody> createState() => _RevisionWorkflowBodyState();
}

class _RevisionWorkflowBodyState extends State<RevisionWorkflowBody> {
  final _commentController = TextEditingController();

  List<ReviewerComment> _comments = const [];
  bool _hasLoaded = false;
  bool _awaitingAdd = false;
  bool _awaitingRevisionUpload = false;

  @override
  void initState() {
    super.initState();
    context.read<PublishingBloc>().add(
          FetchReviewerCommentsRequested(widget.submissionId),
        );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<PublishingBloc>().add(
          FetchReviewerCommentsRequested(widget.submissionId),
        );
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      AppErrorDialog.show(
        context,
        message: 'pasteReviewerCommentBeforeAdding'.tr(),
      );
      return;
    }

    _awaitingAdd = true;
    context.read<PublishingBloc>().add(
          AddReviewerCommentsRequested(widget.submissionId, [text]),
        );
  }

  void _generateResponses() {
    if (_comments.isEmpty) {
      AppErrorDialog.show(
        context,
        message: 'addAtLeastOneReviewerComment'.tr(),
      );
      return;
    }

    context.read<PublishingBloc>().add(
          GenerateResponsesRequested(widget.submissionId),
        );
  }

  Future<void> _pickAndUploadRevision() async {
    if (context.read<PublishingBloc>().state is PublishingLoading) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
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

    _awaitingRevisionUpload = true;
    if (!mounted) return;
    context.read<PublishingBloc>().add(
          UploadRevisionRequested(widget.submissionId, File(path)),
        );
  }

  String? _aiResponseText(ReviewerComment comment) {
    final response = comment.response;
    if (response == null) return null;

    final suggested = response.suggestedResponse.trim();
    final requiredChange = response.requiredChange.trim();
    if (suggested.isEmpty && requiredChange.isEmpty) return null;
    if (requiredChange.isEmpty) return suggested;
    final requiredLine =
        'requiredChangePrefix'.tr(args: [requiredChange]);
    if (suggested.isEmpty) return requiredLine;
    return '$suggested\n\n$requiredLine';
  }

  List<ReviewerComment> _mergeResponses(
    List<ReviewerComment> comments,
    List<ResponseItem> responses,
  ) {
    if (responses.isEmpty) return comments;
    final byCommentId = <String, ResponseItem>{
      for (final item in responses)
        if (item.commentId.isNotEmpty) item.commentId: item,
    };
    return [
      for (final comment in comments)
        byCommentId.containsKey(comment.id)
            ? comment.copyWith(response: byCommentId[comment.id])
            : comment,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublishingBloc, PublishingState>(
      listenWhen: (previous, current) =>
          current is PublishingFailure ||
          current is PublishingCommentsLoaded ||
          current is PublishingResponsesGenerated,
      listener: (context, state) {
        if (state is PublishingFailure) {
          _awaitingAdd = false;
          _awaitingRevisionUpload = false;
          if (_hasLoaded) {
            AppErrorDialog.show(context, message: state.error.tr());
          }
          return;
        }

        if (state is PublishingCommentsLoaded) {
          setState(() {
            _comments = state.comments;
            _hasLoaded = true;
          });
          if (_awaitingAdd) {
            _awaitingAdd = false;
            _commentController.clear();
          }
          if (_awaitingRevisionUpload) {
            _awaitingRevisionUpload = false;
            AppSuccessDialog.show(
              context,
              message: 'revisedManuscriptUploaded'.tr(),
            );
          }
          return;
        }

        if (state is PublishingResponsesGenerated) {
          setState(() {
            _comments = _mergeResponses(_comments, state.responses);
            _hasLoaded = true;
          });
        }
      },
      child: BlocBuilder<PublishingBloc, PublishingState>(
        builder: (context, state) {
          if (!_hasLoaded) {
            if (state is PublishingFailure) {
              return AppErrorWidget(
                message: state.error.tr(),
                onRetry: _fetch,
              );
            }
            return const LoadingWidget();
          }

          final isBusy = state is PublishingLoading;
          final loadingMessage =
              state is PublishingLoading ? state.message : null;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LabeledWidget(
                  labelPadding: const EdgeInsets.only(bottom: 8),
                  label: Text(
                    'reviewerComment'.tr(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  widget: CustomTextField(
                    controller: _commentController,
                    hintText: 'pasteAReviewerComment',
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4000),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: PrimaryButton(
                    text: 'add'.tr(),
                    onPressed: isBusy ? null : _addComment,
                    isLoading: loadingMessage == 'savingComments',
                    width: 96,
                    height: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _comments.isEmpty
                      ? EmptyState(
                          message: 'noReviewerCommentsYet'.tr(),
                        )
                      : ListView.separated(
                          itemCount: _comments.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return ReviewerCommentCard(
                              commentText: comment.commentText,
                              aiResponse: _aiResponseText(comment),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'generateAiResponses'.tr(),
                  onPressed: isBusy ? null : _generateResponses,
                  isLoading: loadingMessage == 'generatingResponses',
                  width: double.infinity,
                  height: 52,
                  icon: Icons.auto_awesome,
                ),
                const SizedBox(height: 12),
                SmallPillButton(
                  label: 'uploadRevisedManuscript'.tr(),
                  width: double.infinity,
                  onPressed: _pickAndUploadRevision,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
