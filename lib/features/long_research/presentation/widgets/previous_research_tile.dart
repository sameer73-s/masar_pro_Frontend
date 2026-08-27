import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/unified_task_card.dart';
import '../../domain/entities/research_job.dart';
import '../../domain/enums/research_status.dart';

/// بلاط بحث سابق من Hive
class PreviousResearchTile extends StatelessWidget {
  final ResearchJob job;
  final VoidCallback? onDownload;
  final VoidCallback? onTap;

  const PreviousResearchTile({
    super.key,
    required this.job,
    this.onDownload,
    this.onTap,
  });

  String _formatDate(DateTime dt) {
    final months = [
      '',
      'monthJanuary'.tr(),
      'monthFebruary'.tr(),
      'monthMarch'.tr(),
      'monthApril'.tr(),
      'monthMay'.tr(),
      'monthJune'.tr(),
      'monthJuly'.tr(),
      'monthAugust'.tr(),
      'monthSeptember'.tr(),
      'monthOctober'.tr(),
      'monthNovember'.tr(),
      'monthDecember'.tr(),
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  double _progressFor(ResearchStatus status) => switch (status) {
        ResearchStatus.pending => 0.0,
        ResearchStatus.outlining => 0.2,
        ResearchStatus.researching => 0.4,
        ResearchStatus.writing => 0.6,
        ResearchStatus.reviewing => 0.75,
        ResearchStatus.assembling => 0.9,
        ResearchStatus.completed => 1.0,
        ResearchStatus.failed || ResearchStatus.cancelled => 0.0,
      };

  @override
  Widget build(BuildContext context) {
    final titleShort = job.title.length > 50
        ? '${job.title.substring(0, 50)}...'
        : job.title;

    return UnifiedTaskCard(
      title: titleShort,
      subtitle: '${job.status.label} · ${_formatDate(job.createdAt)}',
      progress: _progressFor(job.status),
      taskType: UnifiedTaskType.research,
      onTap: onTap ?? onDownload,
    );
  }
}
