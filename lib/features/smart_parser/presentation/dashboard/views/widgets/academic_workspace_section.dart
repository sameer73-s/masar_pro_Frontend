import 'package:flutter/material.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/app_theme.dart';
import '../../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../../academic_workspace/presentation/views/pages/academic_workspace_page.dart';

/// Hero entry into the Academic Workspace journey.
class AcademicWorkspaceSection extends StatelessWidget {
  const AcademicWorkspaceSection({super.key});

  void _openAcademicWorkspace(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AcademicWorkspacePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openAcademicWorkspace(context),
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfacePurple,
                Color(0xFFE8E1FF),
              ],
            ),
            border: Border.all(color: const Color(0xFFE8E5F0)),
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
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Workspace',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Proposal → Research → Publishing in one journey',
                            style: TextStyle(
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
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Open Academic Workspace',
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
