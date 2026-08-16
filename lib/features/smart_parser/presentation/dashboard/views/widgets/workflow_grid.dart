import 'package:flutter/material.dart';
import '../../../../../../config/app_colors.dart';
import 'action_card.dart';

class WorkflowGrid extends StatelessWidget {
  final VoidCallback onSmartParserTap;
  final VoidCallback onContentCreationTap;
  final VoidCallback onResearchTap;
  final VoidCallback onAcademicPublishingTap;

  const WorkflowGrid({
    super.key,
    required this.onSmartParserTap,
    required this.onContentCreationTap,
    required this.onResearchTap,
    required this.onAcademicPublishingTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        ActionCard(
          title: 'المحلل الذكي',
          icon: Icons.document_scanner,
          color: AppColors.accentGold,
          onTap: onSmartParserTap,
        ),
        ActionCard(
          title: 'إنشاء المحتوى',
          icon: Icons.edit_note,
          color: AppColors.accentGold,
          onTap: onContentCreationTap,
        ),
        ActionCard(
          title: 'البحث الطويل',
          icon: Icons.auto_stories,
          color: AppColors.accentGold,
          onTap: onResearchTap,
        ),
        ActionCard(
          title: 'النشر الأكاديمي',
          icon: Icons.publish,
          color: AppColors.accentGold,
          onTap: onAcademicPublishingTap,
        ),
      ],
    );
  }
}
