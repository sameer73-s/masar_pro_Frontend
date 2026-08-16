import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/strings.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';
import 'package:masar_pro/core/presentation/widgets/small_pill_button.dart';

class SmartUploadCard extends StatelessWidget {
  final TextEditingController textController;
  final List<PlatformFile> selectedFiles;
  final VoidCallback onPickFiles;
  final VoidCallback onSubmit;

  const SmartUploadCard({
    super.key,
    required this.textController,
    required this.selectedFiles,
    required this.onPickFiles,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: Strings.enterRequestHint.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.accentGold,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SmallPillButton(
                  label: Strings.attachFiles.tr(),
                  onPressed: onPickFiles,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedFiles.isEmpty
                        ? Strings.noFilesSelected.tr()
                        : Strings.filesSelected.tr(
                            args: [selectedFiles.length.toString()],
                          ),
                    style: TextStyle(color: AppColors.slateGray),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: Strings.analyzeInput.tr(),
              onPressed: onSubmit,
              width: double.infinity,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}
