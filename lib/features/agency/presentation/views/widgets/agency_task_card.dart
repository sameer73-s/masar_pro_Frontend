import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../config/app_theme.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../core/presentation/widgets/status_badge.dart';
import '../../../domain/entities/agency_task.dart';
import '../../../domain/enums/task_status.dart';
import '../../bloc/agency_bloc/agency_bloc.dart';
import 'quote_task_dialog.dart';

class AgencyTaskCard extends StatelessWidget {
  const AgencyTaskCard({super.key, required this.task});

  final AgencyTask task;

  @override
  Widget build(BuildContext context) {
    final category = _categoryStyle(task);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        boxShadow: AppShadows.subtleCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: title + category icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _taskTitle(task),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: category.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(
                  category.icon,
                  size: 14,
                  color: category.fg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Middle: subtitle
          Text(
            _taskSubtitle(task),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Bottom: time + status badge
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(task.createdAt),
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              StatusBadge(
                status: _badgeStatus(task.status),
                label: _badgeLabel(task.status),
              ),
            ],
          ),
          if (task.quotedPrice != null) ...[
            const SizedBox(height: 8),
            Text(
              'Quote: ${task.quotedPrice}',
              style: const TextStyle(
                color: AppColors.accentPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ActionRow(task: task),
        ],
      ),
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
    return 'Client ${task.clientId} · #$shortId';
  }

  static ({IconData icon, Color bg, Color fg}) _categoryStyle(AgencyTask task) {
    return switch (task.status) {
      TaskStatus.completed => (
          icon: Icons.check_circle_outline_rounded,
          bg: AppColors.surfacePurple,
          fg: AppColors.accentPurple,
        ),
      TaskStatus.processing || TaskStatus.approved => (
          icon: Icons.auto_awesome_rounded,
          bg: AppColors.surfaceOrange,
          fg: AppColors.accentOrange,
        ),
      TaskStatus.pendingApproval => (
          icon: Icons.pending_actions_rounded,
          bg: AppColors.surfaceBlue,
          fg: AppColors.statusBlue,
        ),
      _ => (
          icon: Icons.work_outline_rounded,
          bg: AppColors.surfacePink,
          fg: const Color(0xFFE91E8C),
        ),
    };
  }

  static Status _badgeStatus(TaskStatus status) => switch (status) {
        TaskStatus.completed => Status.done,
        TaskStatus.processing || TaskStatus.approved => Status.inProgress,
        _ => Status.toDo,
      };

  static String _badgeLabel(TaskStatus status) => switch (status) {
        TaskStatus.uploaded => 'To-Do',
        TaskStatus.pendingApproval => 'Pending',
        TaskStatus.approved => 'Approved',
        TaskStatus.rejected => 'Rejected',
        TaskStatus.processing => 'In Progress',
        TaskStatus.completed => 'Done',
        TaskStatus.failed => 'Failed',
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
