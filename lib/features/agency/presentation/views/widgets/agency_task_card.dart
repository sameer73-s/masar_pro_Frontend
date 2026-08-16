import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../core/presentation/widgets/unified_task_card.dart';
import '../../../domain/entities/agency_task.dart';
import '../../../domain/enums/task_status.dart';
import '../../bloc/agency_bloc/agency_bloc.dart';
import 'quote_task_dialog.dart';

class AgencyTaskCard extends StatelessWidget {
  const AgencyTaskCard({super.key, required this.task});

  final AgencyTask task;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UnifiedTaskCard(
          title: _taskTitle(task),
          subtitle: _taskSubtitle(task),
          progress: _progressFor(task.status),
          taskType: UnifiedTaskType.research,
        ),
        const SizedBox(height: 8),
        _ActionRow(task: task),
      ],
    );
  }

  static String _taskTitle(AgencyTask task) {
    final folder = task.storageFolder.trim();
    if (folder.isEmpty) return 'Long Research';
    final segment = folder.split(RegExp(r'[/\\]')).lastWhere(
          (s) => s.isNotEmpty,
          orElse: () => folder,
        );
    return segment
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map(
          (w) =>
              '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }

  static String _taskSubtitle(AgencyTask task) {
    final shortId =
        task.id.length > 8 ? '${task.id.substring(0, 8)}…' : task.id;
    final quote = task.quotedPrice != null ? ' · Quote: ${task.quotedPrice}' : '';
    return 'Client ${task.clientId} · #$shortId · ${_formatTime(task.createdAt)}$quote';
  }

  /// UPLOADED → 0.0, PROCESSING → 0.5, COMPLETED → 1.0.
  static double _progressFor(TaskStatus status) => switch (status) {
        TaskStatus.completed => 1.0,
        TaskStatus.processing || TaskStatus.approved => 0.5,
        _ => 0.0,
      };

  static String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour24 = local.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final min = local.minute.toString().padLeft(2, '0');
    return '$hour12:$min $period';
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.task});

  final AgencyTask task;

  @override
  Widget build(BuildContext context) {
    switch (task.status) {
      case TaskStatus.uploaded:
        return Align(
          alignment: Alignment.centerRight,
          child: _TaskActionButton(
            label: 'Quote & Approve',
            onPressed: () => QuoteTaskDialog.show(context, taskId: task.id),
          ),
        );
      case TaskStatus.pendingApproval:
        return Align(
          alignment: Alignment.centerRight,
          child: _TaskActionButton(
            label: 'Process',
            onPressed: () => context.read<AgencyBloc>().add(
                  ApproveTaskRequested(task.id),
                ),
          ),
        );
      case TaskStatus.approved:
        return Align(
          alignment: Alignment.centerRight,
          child: _TaskActionButton(
            label: 'Start Processing',
            onPressed: () => context.read<AgencyBloc>().add(
                  ProcessTaskRequested(
                    task.id,
                    'long_research',
                    const <String, dynamic>{},
                  ),
                ),
          ),
        );
      case TaskStatus.processing:
        return const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Processing…',
              style: TextStyle(
                color: AppColors.accentOrange,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      case TaskStatus.completed:
        return Align(
          alignment: Alignment.centerRight,
          child: _TaskActionButton(
            label: 'Download Result',
            onPressed: () => _downloadResult(context, task.aiResultRef),
          ),
        );
      case TaskStatus.rejected:
      case TaskStatus.failed:
        return Text(
          task.status == TaskStatus.rejected ? 'Rejected' : 'Failed',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  Future<void> _downloadResult(BuildContext context, String? ref) async {
    if (ref == null || ref.isEmpty) {
      AppErrorDialog.show(context, message: 'No result available yet');
      return;
    }

    final uri = Uri.tryParse(
      ref.startsWith('http') ? ref : '${ApiConfig.normalizedBaseUrl}$ref',
    );
    if (uri == null) {
      AppErrorDialog.show(context, message: 'Invalid result URL');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      AppErrorDialog.show(context, message: 'Could not open download link');
    }
  }
}

/// Content-sized pill matching SmallPillButton tokens without fixed width.
class _TaskActionButton extends StatelessWidget {
  const _TaskActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfacePurple,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.accentPurple,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
