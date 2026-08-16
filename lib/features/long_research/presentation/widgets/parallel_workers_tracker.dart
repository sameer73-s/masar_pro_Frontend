import 'package:flutter/material.dart';
import '../../domain/entities/sub_agent_status.dart';
import 'animated_progress_ring.dart';

/// Live list of parallel research workers during the researching stage.
/// Hidden automatically when [workers] is empty.
class ParallelWorkersTracker extends StatelessWidget {
  final List<SubAgentStatus> workers;

  const ParallelWorkersTracker({
    super.key,
    required this.workers,
  });

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) return const SizedBox.shrink();

    final running = workers.where((w) => w.isRunning).length;
    final done = workers.where((w) => w.isCompleted).length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(kCardRadius),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: cardPadding,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub_outlined, size: 18, color: kPrimaryBlue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'عمال البحث المتوازي',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                ),
                Text(
                  '$done/${workers.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
            if (running > 0) ...[
              const SizedBox(height: 6),
              Text(
                '$running يعمل الآن',
                style: const TextStyle(fontSize: 11, color: kTextSecondary),
              ),
            ],
            const SizedBox(height: 12),
            for (int i = 0; i < workers.length; i++) ...[
              _WorkerRow(worker: workers[i]),
              if (i < workers.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkerRow extends StatelessWidget {
  final SubAgentStatus worker;

  const _WorkerRow({required this.worker});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusIcon(status: worker.status),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.section,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                if (worker.message.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    worker.message,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    if (worker.isFailed) return const Color(0xFFFEF2F2);
    if (worker.isCompleted) return const Color(0xFFF0FDF4);
    if (worker.isRunning) return const Color(0xFFEFF6FF);
    return kBgLight;
  }

  Color get _borderColor {
    if (worker.isFailed) return const Color(0xFFFECACA);
    if (worker.isCompleted) return const Color(0xFFBBF7D0);
    if (worker.isRunning) return const Color(0xFFBFDBFE);
    return kBorderColor;
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'completed':
        return const Icon(Icons.check_circle, color: kPrimaryGreen, size: 22);
      case 'failed':
        return const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 22);
      case 'running':
      case 'pending':
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: kPrimaryBlue,
          ),
        );
      default:
        return const Icon(Icons.circle_outlined, color: kTextSecondary, size: 20);
    }
  }
}
