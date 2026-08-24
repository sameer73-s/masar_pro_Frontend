import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/app_theme.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  List<_QuickToolItem> _tools(BuildContext context) {
    return [
      _QuickToolItem(
        emoji: '📊',
        label: 'Excel',
        subtitle: 'Version and compare spreadsheets',
        onTap: () => _push(context, const ExcelVersionerPage()),
      ),
      _QuickToolItem(
        emoji: '🔍',
        label: 'Audit',
        subtitle: 'Quality and originality checks',
        onTap: () => _push(context, const AuditScreen()),
      ),
      _QuickToolItem(
        emoji: '✨',
        label: 'Humanize',
        subtitle: 'Make AI text sound natural',
        onTap: () => _push(context, const HumanizeScreen()),
      ),
      _QuickToolItem(
        emoji: '🧠',
        label: 'Parser',
        subtitle: 'Smart order parsing',
        onTap: () => _push(context, const SmartParserScreen()),
      ),
      _QuickToolItem(
        emoji: '📝',
        label: 'Content Creation',
        subtitle: 'Create tasks and content workflows',
        onTap: () => _push(context, const TaskSelectionPage()),
      ),
      _QuickToolItem(
        emoji: '📚',
        label: 'Research',
        subtitle: 'Long-form research workspace',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider(
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
    final tools = _tools(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
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
            const Text(
              'All Tools',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Jump into any utility from here',
              style: TextStyle(
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
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: tool.onTap,
                    borderRadius: BorderRadius.circular(AppShapes.cardRadius),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppShapes.cardRadius),
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
                          const Icon(
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
