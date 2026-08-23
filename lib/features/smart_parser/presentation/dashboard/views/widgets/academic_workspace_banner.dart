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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAcademicWorkspaceTap,
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
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.accentPurple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Open Academic Workspace',
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
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onActiveTasksTap,
            icon: const Icon(
              Icons.task_alt_rounded,
              size: 18,
              color: AppColors.accentPurple,
            ),
            label: const Text(
              'Active Tasks',
              style: TextStyle(
                color: AppColors.accentPurple,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentPurple,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ),
      ],
    );
  }
}
