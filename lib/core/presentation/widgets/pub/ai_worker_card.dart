import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';

const Color _kPubBorder = AppColors.uiBorder;
const Color _kSuccessGreen = AppColors.uiSuccess;
const Color _kPendingGrey = AppColors.uiPending;

enum AIWorkerState { processing, completed, waiting }

/// Compact AI task row: icon + title, progress bar, and status.
class AIWorkerCard extends StatelessWidget {
  const AIWorkerCard({
    super.key,
    required this.taskTitle,
    required this.progress,
    required this.state,
  });

  final String taskTitle;

  /// Value from 0.0 to 1.0. Ignored when [state] is waiting.
  final double progress;
  final AIWorkerState state;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final displayProgress = switch (state) {
      AIWorkerState.completed => 1.0,
      AIWorkerState.waiting => 0.0,
      AIWorkerState.processing => clamped,
    };
    final barColor = switch (state) {
      AIWorkerState.processing => AppColors.accentPurple,
      AIWorkerState.completed => _kSuccessGreen,
      AIWorkerState.waiting => _kPendingGrey,
    };

    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        side: const BorderSide(color: _kPubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _StateIcon(state: state),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                taskTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: displayProgress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: barColor.withValues(alpha: 0.16),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            _StatusLabel(state: state, progress: displayProgress),
          ],
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.state});

  final AIWorkerState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AIWorkerState.processing => const _RotatingSparkle(),
      AIWorkerState.completed => const Icon(
        Icons.check_circle_rounded,
        size: 20,
        color: _kSuccessGreen,
      ),
      AIWorkerState.waiting => const Icon(
        Icons.hourglass_empty_rounded,
        size: 20,
        color: _kPendingGrey,
      ),
    };
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.state, required this.progress});

  final AIWorkerState state;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final text = switch (state) {
      AIWorkerState.waiting => 'Queued',
      AIWorkerState.completed => '100%',
      AIWorkerState.processing => '${(progress * 100).round()}%',
    };
    final color = switch (state) {
      AIWorkerState.waiting => AppColors.textSecondary,
      AIWorkerState.completed => _kSuccessGreen,
      AIWorkerState.processing => AppColors.accentPurple,
    };

    return SizedBox(
      width: 52,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Restarts a full-turn tween so the sparkle icon keeps rotating.
class _RotatingSparkle extends StatefulWidget {
  const _RotatingSparkle();

  @override
  State<_RotatingSparkle> createState() => _RotatingSparkleState();
}

class _RotatingSparkleState extends State<_RotatingSparkle> {
  Key _tweenKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: _tweenKey,
      tween: Tween(begin: 0, end: math.pi * 2),
      duration: const Duration(seconds: 2),
      curve: Curves.linear,
      onEnd: () {
        if (!mounted) return;
        setState(() => _tweenKey = UniqueKey());
      },
      builder: (context, angle, child) {
        return Transform.rotate(angle: angle, child: child);
      },
      child: const Icon(
        Icons.auto_awesome,
        size: 20,
        color: AppColors.accentPurple,
      ),
    );
  }
}
