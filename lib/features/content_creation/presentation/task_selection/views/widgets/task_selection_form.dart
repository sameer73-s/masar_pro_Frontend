import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../config/app_colors.dart';
import '../../../task_form/views/task_form_page.dart';

class TaskItem {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TaskItem({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class TaskSelectionForm extends StatelessWidget {
  const TaskSelectionForm({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TaskItem> tasks = [
      TaskItem(
        key: 'research',
        title: 'taskTypeResearch'.tr(),
        description: 'taskTypeResearchDesc'.tr(),
        icon: Icons.school_outlined,
        color: const Color(0xFF6366F1),
      ),
      TaskItem(
        key: 'presentation',
        title: 'taskTypePresentation'.tr(),
        description: 'taskTypePresentationDesc'.tr(),
        icon: Icons.slideshow_rounded,
        color: const Color(0xFFF59E0B),
      ),
      TaskItem(
        key: 'case_study',
        title: 'taskTypeCaseStudy'.tr(),
        description: 'taskTypeCaseStudyDesc'.tr(),
        icon: Icons.analytics_outlined,
        color: const Color(0xFF10B981),
      ),
      TaskItem(
        key: 'report',
        title: 'taskTypeReport'.tr(),
        description: 'taskTypeReportDesc'.tr(),
        icon: Icons.assignment_outlined,
        color: const Color(0xFF3B82F6),
      ),
      TaskItem(
        key: 'essay',
        title: 'taskTypeEssay'.tr(),
        description: 'taskTypeEssayDesc'.tr(),
        icon: Icons.article_outlined,
        color: const Color(0xFF8B5CF6),
      ),
      TaskItem(
        key: 'summary',
        title: 'taskTypeSummary'.tr(),
        description: 'taskTypeSummaryDesc'.tr(),
        icon: Icons.menu_book_outlined,
        color: const Color(0xFFEC4899),
      ),
      TaskItem(
        key: 'project',
        title: 'taskTypeProject'.tr(),
        description: 'taskTypeProjectDesc'.tr(),
        icon: Icons.business_center_outlined,
        color: const Color(0xFFEF4444),
      ),
      TaskItem(
        key: 'literature_review',
        title: 'taskTypeLiteratureReview'.tr(),
        description: 'taskTypeLiteratureReviewDesc'.tr(),
        icon: Icons.library_books_outlined,
        color: const Color(0xFF06B6D4),
      ),
      TaskItem(
        key: 'homework',
        title: 'taskTypeHomework'.tr(),
        description: 'taskTypeHomeworkDesc'.tr(),
        icon: Icons.quiz_outlined,
        color: const Color(0xFFF43F5E),
      ),
      TaskItem(
        key: 'translation',
        title: 'taskTypeTranslation'.tr(),
        description: 'taskTypeTranslationDesc'.tr(),
        icon: Icons.translate_rounded,
        color: const Color(0xFF0EA5E9),
      ),
      TaskItem(
        key: 'paraphrase',
        title: 'taskTypeParaphrase'.tr(),
        description: 'taskTypeParaphraseDesc'.tr(),
        icon: Icons.history_edu_outlined,
        color: const Color(0xFF10B981),
      ),
      TaskItem(
        key: 'cv',
        title: 'taskTypeCv'.tr(),
        description: 'taskTypeCvDesc'.tr(),
        icon: Icons.contact_page_outlined,
        color: const Color(0xFF64748B),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TaskFormPage(task: task),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: task.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        task.icon,
                        color: task.color,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.slateGray,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
