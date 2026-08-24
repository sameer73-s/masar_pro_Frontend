import 'package:flutter/material.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../content_creation/presentation/task_selection/views/task_selection_page.dart';
import '../../../../../excel_versioner/excel_versioner_page.dart';
import '../../../../../quality/presentation/screens/audit_screen.dart';
import '../../../../../quality/presentation/screens/humanize_screen.dart';
import '../../../smart_parser/views/smart_parser_page.dart';
import 'quick_tool_chip.dart';
import 'quick_tools_bottom_sheet.dart';

/// Compact utility row of quick-access tool chips.
class QuickToolsSection extends StatelessWidget {
  const QuickToolsSection({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = <QuickToolChip>[
      QuickToolChip(
        icon: Icons.table_chart_rounded,
        emoji: '📊',
        label: 'Excel',
        onTap: () => _push(context, const ExcelVersionerPage()),
      ),
      QuickToolChip(
        icon: Icons.search_rounded,
        emoji: '🔍',
        label: 'Audit',
        onTap: () => _push(context, const AuditScreen()),
      ),
      QuickToolChip(
        icon: Icons.auto_awesome_rounded,
        emoji: '✨',
        label: 'Humanize',
        onTap: () => _push(context, const HumanizeScreen()),
      ),
      QuickToolChip(
        icon: Icons.psychology_rounded,
        emoji: '🧠',
        label: 'Parser',
        onTap: () => _push(context, const SmartParserScreen()),
      ),
      QuickToolChip(
        icon: Icons.create_new_folder_rounded,
        emoji: '📝',
        label: 'Create',
        onTap: () => _push(context, const TaskSelectionPage()),
      ),
      QuickToolChip(
        icon: Icons.more_horiz_rounded,
        emoji: '⋯',
        label: 'More',
        onTap: () => QuickToolsBottomSheet.show(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Tools',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chips.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => chips[index],
          ),
        ),
      ],
    );
  }
}
