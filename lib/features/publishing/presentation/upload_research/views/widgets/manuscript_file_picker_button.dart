import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';

const Color _kPubBorder = Color(0xFFE8E5F0);

class ManuscriptFilePickerButton extends StatelessWidget {
  const ManuscriptFilePickerButton({
    super.key,
    required this.onPressed,
    this.fileName,
    this.enabled = true,
    this.emptyTitle = 'selectManuscript',
    this.emptySubtitle = 'pdfOrDocxMockedPicker',
    this.selectedSubtitle = 'tapToReplaceMocked',
  });

  final VoidCallback onPressed;
  final String? fileName;
  final bool enabled;
  final String emptyTitle;
  final String emptySubtitle;
  final String selectedSubtitle;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null && fileName!.isNotEmpty;

    return Material(
      color: AppColors.surfacePurple,
      borderRadius: BorderRadius.circular(AppShapes.cardRadius),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            border: Border.all(color: _kPubBorder),
          ),
          child: Row(
            children: [
              Icon(
                hasFile
                    ? Icons.description_outlined
                    : Icons.upload_file_outlined,
                color: AppColors.accentPurple,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFile ? fileName! : emptyTitle.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasFile ? selectedSubtitle.tr() : emptySubtitle.tr(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.accentPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
