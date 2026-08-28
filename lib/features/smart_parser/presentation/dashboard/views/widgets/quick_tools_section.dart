import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/constants.dart';
import '../../../../../../core/presentation/widgets/premium_page_route.dart';
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
    Navigator.of(context).push(premiumPageRoute<void>(page));
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final chips = <QuickToolChip>[
      QuickToolChip(
        icon: Icons.table_chart_rounded,
        emoji: '📊',
        label: 'toolExcel'.tr(),
        onTap: () => _push(context, const ExcelVersionerPage()),
      ),
      QuickToolChip(
        icon: Icons.search_rounded,
        emoji: '🔍',
        label: 'toolAudit'.tr(),
        onTap: () => _push(context, const AuditScreen()),
      ),
      QuickToolChip(
        icon: Icons.auto_awesome_rounded,
        emoji: '✨',
        label: 'toolHumanize'.tr(),
        onTap: () => _push(context, const HumanizeScreen()),
      ),
      QuickToolChip(
        icon: Icons.psychology_rounded,
        emoji: '🧠',
        label: 'toolParser'.tr(),
        onTap: () => _push(context, const SmartParserScreen()),
      ),
      QuickToolChip(
        icon: Icons.create_new_folder_rounded,
        emoji: '📝',
        label: 'toolCreate'.tr(),
        onTap: () => _push(context, const TaskSelectionPage()),
      ),
      QuickToolChip(
        icon: Icons.more_horiz_rounded,
        emoji: '⋯',
        label: 'toolMore'.tr(),
        onTap: () => QuickToolsBottomSheet.show(context),
      ),
    ];

    return Column(
      key: ValueKey(locale.languageCode),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quickTools'.tr(),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: kSpacing12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chips.length,
            separatorBuilder: (_, _) => const SizedBox(width: kSpacing12),
            itemBuilder: (context, index) => chips[index],
          ),
        ),
      ],
    );
  }
}
