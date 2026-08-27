import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_text_field.dart';
import 'package:masar_pro/core/presentation/widgets/labeled_widget.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';

import 'manuscript_file_picker_button.dart';

class UploadResearchForm extends StatelessWidget {
  const UploadResearchForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.onPickFile,
    required this.onSubmit,
    this.fileName,
    this.enabled = true,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final VoidCallback onPickFile;
  final VoidCallback onSubmit;
  final String? fileName;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          LabeledWidget(
            labelPadding: const EdgeInsets.only(bottom: 8),
            label: Text(
              'researchTitle'.tr(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            widget: CustomTextField(
              controller: titleController,
              hintText: 'enterYourResearchTitle',
              validationMessage: 'pleaseEnterResearchTitle'.tr(),
              textInputAction: TextInputAction.done,
              readOnly: !enabled,
            ),
          ),
          const SizedBox(height: 20),
          LabeledWidget(
            labelPadding: const EdgeInsets.only(bottom: 8),
            label: Text(
              'manuscript'.tr(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            widget: ManuscriptFilePickerButton(
              fileName: fileName,
              onPressed: onPickFile,
              enabled: enabled,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'submitAndAnalyze'.tr(),
            onPressed: enabled ? onSubmit : null,
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}
