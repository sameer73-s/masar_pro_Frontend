import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/constants.dart';
import '../../../../../../config/app_theme.dart';
import '../../../../../../core/presentation/widgets/premium_page_route.dart';
import '../../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../../academic_workspace/presentation/views/pages/academic_workspace_page.dart';

/// Hero entry into the Academic Workspace journey.
class AcademicWorkspaceSection extends StatelessWidget {
  const AcademicWorkspaceSection({super.key});

  void _openAcademicWorkspace(BuildContext context) {
    Navigator.of(
      context,
    ).push(premiumPageRoute<void>(const AcademicWorkspacePage()));
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Material(
      key: ValueKey(locale.languageCode),
      color: AppColors.transparent,
      child: InkWell(
        onTap: () => _openAcademicWorkspace(context),
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surfacePurple, AppColors.surfacePurple],
            ),
            border: Border.all(color: AppColors.border),
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
                    const SizedBox(width: kSpacing16),
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
                  ],
                ),
                const SizedBox(height: kSpacing16),
                PrimaryButton(
                  text: 'openAcademicWorkspace'.tr(),
                  onPressed: () => _openAcademicWorkspace(context),
                  width: double.infinity,
                  height: 46,
                  icon: Icons.auto_stories_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
