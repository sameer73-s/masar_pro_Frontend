import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/app_theme.dart';
import '../../../../../../core/presentation/widgets/premium_page_route.dart';
import '../../../../../../injection/injection_container.dart' as di;
import '../../../../../content_creation/presentation/task_selection/views/task_selection_page.dart';
import '../../../../../excel_versioner/excel_versioner_page.dart';
import '../../../../../long_research/presentation/bloc/research_bloc.dart';
import '../../../../../long_research/presentation/screens/research_hub_screen.dart';
import '../../../../../quality/presentation/screens/audit_screen.dart';
import '../../../../../quality/presentation/screens/humanize_screen.dart';
import '../../../smart_parser/views/smart_parser_page.dart';

class _QuickToolItem {
  const _QuickToolItem({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
}

/// Modal listing all quick tools available from the dashboard.
class QuickToolsBottomSheet extends StatelessWidget {
  const QuickToolsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.cardRadius),
        ),
      ),
      builder: (_) => const QuickToolsBottomSheet(),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(premiumPageRoute<void>(page));
  }

  List<_QuickToolItem> _tools(BuildContext context) {
    return [
      _QuickToolItem(
        emoji: '📊',
        label: 'toolExcel'.tr(),
        subtitle: 'toolExcelSubtitle'.tr(),
        onTap: () => _push(context, const ExcelVersionerPage()),
      ),
      _QuickToolItem(
        emoji: '🔍',
        label: 'toolAudit'.tr(),
        subtitle: 'toolAuditSubtitle'.tr(),
        onTap: () => _push(context, const AuditScreen()),
      ),
      _QuickToolItem(
        emoji: '✨',
        label: 'toolHumanize'.tr(),
        subtitle: 'toolHumanizeSubtitle'.tr(),
        onTap: () => _push(context, const HumanizeScreen()),
      ),
      _QuickToolItem(
        emoji: '🧠',
        label: 'toolParser'.tr(),
        subtitle: 'toolParserSubtitle'.tr(),
        onTap: () => _push(context, const SmartParserScreen()),
      ),
      _QuickToolItem(
        emoji: '📝',
        label: 'toolContentCreation'.tr(),
        subtitle: 'toolContentCreationSubtitle'.tr(),
        onTap: () => _push(context, const TaskSelectionPage()),
      ),
      _QuickToolItem(
        emoji: '📚',
        label: 'toolResearch'.tr(),
        subtitle: 'toolResearchSubtitle'.tr(),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            premiumPageRoute<void>(
              BlocProvider(
                create: (_) => di.locator<ResearchBloc>(),
                child: const ResearchHubScreen(),
              ),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final tools = _tools(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      key: ValueKey(locale.languageCode),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'allTools'.tr(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'allToolsSubtitle'.tr(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tool = tools[index];
                return Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: tool.onTap,
                    borderRadius: BorderRadius.circular(AppShapes.cardRadius),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(
                          AppShapes.cardRadius,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfacePurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tool.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tool.label,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tool.subtitle,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
