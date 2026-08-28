import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';

const Color _kPubBorder = AppColors.uiBorder;
const Color _kPendingGrey = AppColors.uiPending;

enum TimelineEventState { completed, current, pending }

class TimelineEvent {
  const TimelineEvent({
    required this.title,
    required this.timestamp,
    required this.state,
  });

  final String title;
  final String timestamp;
  final TimelineEventState state;
}

/// Vertical submission timeline with solid, pulsing, and dashed segments.
class SubmissionTimelineWidget extends StatelessWidget {
  const SubmissionTimelineWidget({super.key, required this.events});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        side: const BorderSide(color: _kPubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            for (var i = 0; i < events.length; i++)
              _TimelineRow(event: events[i], isLast: i == events.length - 1),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.isLast});

  final TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCompleted = event.state == TimelineEventState.completed;
    final isCurrent = event.state == TimelineEventState.current;
    final lineColor = isCompleted ? AppColors.accentPurple : _kPendingGrey;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                _TimelineDot(state: event.state),
                if (!isLast)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isCompleted
                          ? Container(width: 2, color: AppColors.accentPurple)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return CustomPaint(
                                  size: Size(2, constraints.maxHeight),
                                  painter: _DashedLinePainter(color: lineColor),
                                );
                              },
                            ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 8 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.timestamp,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.state});

  final TimelineEventState state;

  @override
  Widget build(BuildContext context) {
    final color = state == TimelineEventState.pending
        ? _kPendingGrey
        : AppColors.accentPurple;

    final dot = Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );

    if (state != TimelineEventState.current) return dot;
    return _PulsingDot(child: dot);
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.child});

  final Widget child;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> {
  bool _forward = true;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _forward ? 0.75 : 1.15, end: _forward ? 1.15 : 0.75),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      onEnd: () {
        if (!mounted) return;
        setState(() => _forward = !_forward);
      },
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0;
    const gap = 3.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    var y = 0.0;
    final x = size.width / 2;
    while (y < size.height) {
      final end = (y + dash).clamp(0.0, size.height);
      canvas.drawLine(Offset(x, y), Offset(x, end), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
