import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';
import 'package:masar_pro/core/presentation/widgets/custom_circular_progress.dart';

const Color _kPubBorder = Color(0xFFE8E5F0);

const Color _kSuccessGreen = Color(0xFF22C55E);
const Color _kWarningYellow = Color(0xFFD97706);
const Color _kBlockerRed = Color(0xFFEF4444);

enum ReadinessCheckStatus { ready, warning, blocker }

class ReadinessCheck {
  const ReadinessCheck({
    required this.label,
    required this.status,
  });

  final String label;
  final ReadinessCheckStatus status;
}

/// Overall manuscript-readiness gauge with a checklist of gates.
class ReadinessScoreCard extends StatelessWidget {
  const ReadinessScoreCard({
    super.key,
    required this.score,
    required this.checks,
  });

  /// Value from 0.0 to 1.0.
  final double score;
  final List<ReadinessCheck> checks;

  ReadinessCheckStatus get _overallStatus {
    if (checks.any((c) => c.status == ReadinessCheckStatus.blocker)) {
      return ReadinessCheckStatus.blocker;
    }
    if (checks.any((c) => c.status == ReadinessCheckStatus.warning)) {
      return ReadinessCheckStatus.warning;
    }
    if (checks.isEmpty) {
      if (score >= 0.8) return ReadinessCheckStatus.ready;
      if (score >= 0.5) return ReadinessCheckStatus.warning;
      return ReadinessCheckStatus.blocker;
    }
    return ReadinessCheckStatus.ready;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0.0, 1.0);
    final status = _overallStatus;
    final gaugeColor = switch (status) {
      ReadinessCheckStatus.ready => _kSuccessGreen,
      ReadinessCheckStatus.warning => AppColors.accentYellow,
      ReadinessCheckStatus.blocker => _kBlockerRed,
    };

    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        side: const BorderSide(color: _kPubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomCircularProgress(
                  progress: value,
                  size: 120,
                  strokeWidth: 10,
                  trackColor: gaugeColor.withValues(alpha: 0.15),
                  progressColor: gaugeColor,
                  textColor: AppColors.primary,
                  textSize: 28,
                );
              },
            ),
            const SizedBox(height: 16),
            _ReadinessStatusBadge(status: status),
            if (checks.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final check in checks) ...[
                _CheckRow(check: check),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadinessStatusBadge extends StatelessWidget {
  const _ReadinessStatusBadge({required this.status});

  final ReadinessCheckStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      ReadinessCheckStatus.ready => (
          _kSuccessGreen.withValues(alpha: 0.12),
          _kSuccessGreen,
          'READY',
        ),
      ReadinessCheckStatus.warning => (
          AppColors.surfaceYellow,
          _kWarningYellow,
          'WARNING',
        ),
      ReadinessCheckStatus.blocker => (
          _kBlockerRed.withValues(alpha: 0.12),
          _kBlockerRed,
          'BLOCKER',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check});

  final ReadinessCheck check;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (check.status) {
      ReadinessCheckStatus.ready => (Icons.check_circle_rounded, _kSuccessGreen),
      ReadinessCheckStatus.warning => (
          Icons.warning_amber_rounded,
          _kWarningYellow,
        ),
      ReadinessCheckStatus.blocker => (Icons.cancel_rounded, _kBlockerRed),
    };

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            check.label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
