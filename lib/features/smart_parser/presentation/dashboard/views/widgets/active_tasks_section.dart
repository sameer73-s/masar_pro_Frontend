import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/app_theme.dart';
import '../../../../../../core/presentation/widgets/premium_page_route.dart';
import '../../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../../agency/presentation/views/pages/agency_dashboard_page.dart';

/// Compact operational card summarizing active / processing task counts.
class ActiveTasksSection extends StatelessWidget {
  const ActiveTasksSection({
    super.key,
    this.activeCount = 8,
    this.processingCount = 3,
  });

  final int activeCount;
  final int processingCount;

  void _openActiveTasks(BuildContext context) {
    Navigator.of(
      context,
    ).push(premiumPageRoute<void>(const AgencyDashboardPage()));
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Container(
      key: ValueKey(locale.languageCode),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtleCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfacePurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.accentPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'activeTasks'.tr(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'activeTasksSummary'.tr(args: ['$activeCount', '$processingCount']),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: PrimaryButton(
              text: 'openActiveTasks'.tr(),
              onPressed: () => _openActiveTasks(context),
              width: 190,
              height: 42,
              backgroundColor: AppColors.surfacePurple,
              textColor: AppColors.accentPurple,
              borderRadius: 12,
              icon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
