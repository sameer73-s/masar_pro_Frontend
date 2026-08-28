import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/app_theme.dart';
import '../../../../../../core/presentation/widgets/primary_button.dart';

/// Primary dashboard entry into Academic Workspace, with Active Tasks shortcut.
class AcademicWorkspaceBanner extends StatelessWidget {
  const AcademicWorkspaceBanner({
    super.key,
    required this.onAcademicWorkspaceTap,
    required this.onActiveTasksTap,
  });

  final VoidCallback onAcademicWorkspaceTap;
  final VoidCallback onActiveTasksTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      key: ValueKey(locale.languageCode),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onAcademicWorkspaceTap,
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppShapes.cardRadius),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.surfacePurple, AppColors.surfacePurple],
                ),
                border: Border.all(color: AppColors.uiBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.background,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'academicWorkspace'.tr(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'academicWorkspaceSubtitle'.tr(),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.accentPurple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'openAcademicWorkspace'.tr(),
                      onPressed: onAcademicWorkspaceTap,
                      width: double.infinity,
                      height: 46,
                      icon: Icons.auto_stories_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: PrimaryButton(
            text: 'activeTasks'.tr(),
            onPressed: onActiveTasksTap,
            icon: Icons.task_alt_rounded,
            width: 170,
            height: 42,
            backgroundColor: AppColors.surfacePurple,
            textColor: AppColors.accentPurple,
            borderRadius: 12,
          ),
        ),
      ],
    );
  }
}
