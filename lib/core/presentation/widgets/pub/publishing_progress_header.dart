import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';

const Color _kPubBorder = Color(0xFFE8E5F0);
const Color _kPendingGrey = Color(0xFFC5C0D3);

/// Horizontal stepper for the five academic-publishing stages.
class PublishingProgressHeader extends StatelessWidget {
  const PublishingProgressHeader({
    super.key,
    required this.currentStage,
    this.stages = defaultStages,
  });

  /// 0-indexed stage that is currently active.
  final int currentStage;

  /// Stage labels, left to right.
  final List<String> stages;

  static const List<String> defaultStages = [
    'Research',
    'Journal',
    'Manuscript',
    'Submission',
    'Revision',
  ];

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) return const SizedBox.shrink();

    final activeIndex = currentStage.clamp(0, stages.length - 1);

    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        side: const BorderSide(color: _kPubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < stages.length; i++)
              Expanded(
                child: _StageColumn(
                  index: i,
                  label: stages[i],
                  currentStage: activeIndex,
                  isFirst: i == 0,
                  isLast: i == stages.length - 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StageColumn extends StatelessWidget {
  const _StageColumn({
    required this.index,
    required this.label,
    required this.currentStage,
    required this.isFirst,
    required this.isLast,
  });

  final int index;
  final String label;
  final int currentStage;
  final bool isFirst;
  final bool isLast;

  bool get _isCompleted => index < currentStage;
  bool get _isCurrent => index == currentStage;

  @override
  Widget build(BuildContext context) {
    final leftDone = index - 1 < currentStage && !isFirst;
    final rightDone = index < currentStage && !isLast;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          child: Row(
            children: [
              Expanded(
                child: isFirst
                    ? const SizedBox.shrink()
                    : _Connector(completed: leftDone),
              ),
              _StageNode(
                index: index,
                isCompleted: _isCompleted,
                isCurrent: _isCurrent,
              ),
              Expanded(
                child: isLast
                    ? const SizedBox.shrink()
                    : _Connector(completed: rightDone),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: _isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: _isCompleted || _isCurrent
                ? AppColors.accentPurple
                : AppColors.textSecondary,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
  });

  final int index;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final fill = (isCompleted || isCurrent)
        ? AppColors.accentPurple
        : _kPendingGrey;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: isCurrent ? 1.08 : 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: _kPendingGrey,
        end: completed ? AppColors.accentPurple : _kPendingGrey,
      ),
      duration: const Duration(milliseconds: 350),
      builder: (context, color, _) {
        return Container(
          height: 2,
          color: color,
        );
      },
    );
  }
}
