import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

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
        Stack(
          clipBehavior: Clip.none,
          children: [
            UnifiedTaskCard(
              title: _taskTitle(task),
              subtitle: _taskSubtitle(task),
              progress: task.progress,
              taskType: UnifiedTaskType.research,
            ),
            Positioned(
              top: 4,
              right: 4,
              child: _TaskOverflowMenu(task: task),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _AgencyTaskStatusBadge(status: task.status),
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
    final quote =
        task.quotedPrice != null ? ' · Quote: ${task.quotedPrice}' : '';
    return 'Client ${task.clientId} · #$shortId · ${_formatTime(task.createdAt)}$quote';
  }

  static String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour24 = local.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final min = local.minute.toString().padLeft(2, '0');
    return '$hour12:$min $period';
  }
}

class _TaskOverflowMenu extends StatelessWidget {
  const _TaskOverflowMenu({required this.task});

  final AgencyTask task;

  bool get _canDelete =>
      task.status == TaskStatus.completed ||
      task.status == TaskStatus.failed ||
      task.status == TaskStatus.rejected;

  bool get _canRetry => task.status == TaskStatus.failed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<_TaskMenuAction>(
        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
        padding: EdgeInsets.zero,
        onSelected: (action) => _handleAction(context, action),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _TaskMenuAction.viewDetails,
            child: ListTile(
              leading: Icon(Icons.info_outline, size: 20),
              title: Text('View Details'),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
          if (_canRetry)
            const PopupMenuItem(
              value: _TaskMenuAction.retry,
              child: ListTile(
                leading: Icon(Icons.refresh, size: 20),
                title: Text('Retry'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (_canDelete)
            PopupMenuItem(
              value: _TaskMenuAction.delete,
              child: ListTile(
                leading: Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                title: Text('Delete', style: TextStyle(color: AppColors.error)),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, _TaskMenuAction action) {
    switch (action) {
      case _TaskMenuAction.viewDetails:
        _TaskDetailsDialog.show(context, task);
      case _TaskMenuAction.retry:
        context.read<AgencyBloc>().add(RetryTaskRequested(task.id));
      case _TaskMenuAction.delete:
        _confirmDelete(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    final shortId =
        task.id.length > 8 ? '${task.id.substring(0, 8)}…' : task.id;
    AppErrorDialog.show(
      context,
      title: 'Delete Task',
      message: 'Task #$shortId will be removed. This action cannot be undone.',
      okButtonText: 'Delete',
      onOk: () => context.read<AgencyBloc>().add(DeleteTaskRequested(task.id)),
      secondaryButtonText: 'Cancel',
      onSecondaryAction: () {},
    );
  }
}

enum _TaskMenuAction { viewDetails, retry, delete }

class _TaskDetailsDialog extends StatelessWidget {
  const _TaskDetailsDialog({required this.task});

  final AgencyTask task;

  static void show(BuildContext context, AgencyTask task) {
    showDialog<void>(
      context: context,
      builder: (_) => _TaskDetailsDialog(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Task Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow('ID', task.id),
            _detailRow('Client', task.clientId),
            _detailRow('Status', task.status.apiValue),
            _detailRow('Progress', '${task.progressPct}%'),
            if (task.quotedPrice != null)
              _detailRow('Quote', '${task.quotedPrice}'),
            _detailRow('Created', task.createdAt.toLocal().toString()),
            _detailRow('Deadline', task.deadline.toLocal().toString()),
            if (task.storageFolder.isNotEmpty)
              _detailRow('Storage', task.storageFolder),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.primary, fontSize: 13),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgencyTaskStatusBadge extends StatelessWidget {
  const _AgencyTaskStatusBadge({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color bg, Color fg, String label) = switch (status) {
      TaskStatus.uploaded => (
          Icons.cloud_upload_outlined,
          AppColors.surfaceBlue,
          AppColors.statusBlue,
          'Uploaded',
        ),
      TaskStatus.pendingApproval => (
          Icons.hourglass_top_outlined,
          AppColors.surfaceOrange,
          AppColors.accentOrange,
          'Pending Approval',
        ),
      TaskStatus.approved => (
          Icons.check_circle_outline,
          AppColors.surfacePurple,
          AppColors.accentPurple,
          'Approved',
        ),
      TaskStatus.processing => (
          Icons.autorenew,
          AppColors.surfaceOrange,
          AppColors.accentOrange,
          'Processing',
        ),
      TaskStatus.completed => (
          Icons.task_alt,
          AppColors.surfacePurple,
          AppColors.accentPurple,
          'Completed',
        ),
      TaskStatus.failed => (
          Icons.error_outline,
          AppColors.darkerRed.withValues(alpha: 0.12),
          AppColors.error,
          'Failed',
        ),
      TaskStatus.rejected => (
          Icons.block,
          AppColors.darkerRed.withValues(alpha: 0.12),
          AppColors.error,
          'Rejected',
        ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatefulWidget {
  const _ActionRow({required this.task});

  final AgencyTask task;

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _isDownloading = false;

  AgencyTask get task => widget.task;

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
        return const _StatusProgressRow(label: 'Processing…');
      case TaskStatus.completed:
        if (_isDownloading) {
          return const _StatusProgressRow(label: 'Downloading…');
        }
        return Align(
          alignment: Alignment.centerRight,
          child: _TaskActionButton(
            label: 'Download Result',
            onPressed: () => _downloadAndOpenResult(task.aiResultRef),
          ),
        );
      case TaskStatus.rejected:
        return const SizedBox.shrink();
      case TaskStatus.failed:
        return Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => context.read<AgencyBloc>().add(
                  RetryTaskRequested(task.id),
                ),
            icon: Icon(Icons.refresh, size: 18, color: AppColors.error),
            label: Text(
              'Retry',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
    }
  }

  Future<void> _downloadAndOpenResult(String? ref) async {
    if (ref == null || ref.isEmpty) {
      AppErrorDialog.show(context, message: 'No result available yet');
      return;
    }

    final url = ref.startsWith('http')
        ? ref
        : '${ApiConfig.normalizedBaseUrl}$ref';
    final uri = Uri.tryParse(url);
    if (uri == null) {
      AppErrorDialog.show(context, message: 'Invalid result URL');
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final dir = await getTemporaryDirectory();
      final fileName = _fileNameFromUri(uri);
      final savePath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      await dio.download(url, savePath);

      final openResult = await OpenFilex.open(savePath);
      if (!mounted) return;
      if (openResult.type != ResultType.done) {
        AppErrorDialog.show(
          context,
          message: openResult.message.isNotEmpty
              ? openResult.message
              : 'Could not open the file',
        );
      }
    } catch (_) {
      if (mounted) {
        AppErrorDialog.show(context, message: 'Download failed');
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  static String _fileNameFromUri(Uri uri) {
    final last = uri.pathSegments.isNotEmpty
        ? Uri.decodeComponent(uri.pathSegments.last)
        : '';
    final cleaned = last.split('?').first.trim();
    if (cleaned.isEmpty || !cleaned.contains('.')) {
      return 'result.docx';
    }
    return cleaned.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  }
}

class _StatusProgressRow extends StatelessWidget {
  const _StatusProgressRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.accentOrange,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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
