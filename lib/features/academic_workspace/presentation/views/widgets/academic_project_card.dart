import 'package:flutter/material.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../config/app_theme.dart';
import '../../../../../core/presentation/widgets/academic_journey_header.dart';
import '../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../../core/presentation/widgets/status_badge.dart';
import '../../../domain/entities/academic_project.dart';
import '../pages/academic_project_placeholder_page.dart';

class AcademicProjectCard extends StatelessWidget {
  const AcademicProjectCard({super.key, required this.project});

  final AcademicProject project;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                status: Status.toDo,
                label: project.academicLevel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AcademicJourneyHeader(
            proposalStatus: project.proposalStatus,
            researchStatus: project.researchStatus,
            publishingStatus: project.publishingStatus,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'View Project',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AcademicProjectPlaceholderPage(
                    projectId: project.id,
                    projectTitle: project.title,
                  ),
                ),
              );
            },
            width: double.infinity,
            height: 42,
            borderRadius: 10,
            backgroundColor: AppColors.surfacePurple,
            textColor: AppColors.accentPurple,
          ),
        ],
      ),
    );
  }
}
