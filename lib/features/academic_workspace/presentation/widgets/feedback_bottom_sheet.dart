import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../publishing/presentation/upload_research/views/widgets/manuscript_file_picker_button.dart';

enum FeedbackSource { doctor, student }

typedef FeedbackSubmitCallback = void Function(
  String feedbackText,
  File? feedbackFile,
  String instructions,
);

class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({
    super.key,
    required this.feedbackSource,
    required this.onSubmit,
  });

  final FeedbackSource feedbackSource;
  final FeedbackSubmitCallback onSubmit;

  static Future<void> show(
    BuildContext context, {
    required FeedbackSource feedbackSource,
    required FeedbackSubmitCallback onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.cardRadius),
        ),
      ),
      builder: (_) => FeedbackBottomSheet(
        feedbackSource: feedbackSource,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final _feedbackController = TextEditingController();
  final _instructionsController = TextEditingController();

  File? _feedbackFile;
  String? _feedbackFileName;
  String? _error;

  String get _title => switch (widget.feedbackSource) {
        FeedbackSource.doctor => 'doctorFeedback'.tr(),
        FeedbackSource.student => 'studentFeedback'.tr(),
      };

  @override
  void dispose() {
    _feedbackController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickFeedbackFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    final path = picked.path;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      setState(() => _error = 'couldNotReadSelectedFile'.tr());
      return;
    }

    setState(() {
      _feedbackFile = File(path);
      _feedbackFileName = picked.name;
      _error = null;
    });
  }

  void _submit() {
    final feedbackText = _feedbackController.text.trim();
    final instructions = _instructionsController.text.trim();

    if (feedbackText.isEmpty && _feedbackFile == null) {
      setState(() => _error = 'feedbackRequired'.tr());
      return;
    }

    widget.onSubmit(feedbackText, _feedbackFile, instructions);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      key: ValueKey(locale.languageCode),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'feedbackShareHint'.tr(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'feedback'.tr(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _feedbackController,
              hintText: 'pasteFeedbackHint'.tr(),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              inputFormatters: [
                LengthLimitingTextInputFormatter(4000),
              ],
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 14),
            ManuscriptFilePickerButton(
              onPressed: _pickFeedbackFile,
              fileName: _feedbackFileName,
              emptyTitle: 'uploadFeedbackFile'.tr(),
              emptySubtitle: 'feedbackFileTypes'.tr(),
              selectedSubtitle: 'tapToReplace'.tr(),
            ),
            const SizedBox(height: 14),
            Text(
              'additionalInstructions'.tr(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _instructionsController,
              hintText: 'additionalInstructionsHint'.tr(),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              inputFormatters: [
                LengthLimitingTextInputFormatter(2000),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'generateAiRevision'.tr(),
              onPressed: _submit,
              width: double.infinity,
              height: 48,
              icon: Icons.auto_awesome,
            ),
          ],
        ),
      ),
    );
  }
}
