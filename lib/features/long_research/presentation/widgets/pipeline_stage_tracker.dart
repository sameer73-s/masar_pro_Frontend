import 'package:flutter/material.dart';
import '../../domain/enums/research_status.dart';
import 'animated_progress_ring.dart';

/// مرحلة واحدة في خط أنابيب البحث
class _PipelineStage {
  final String label;
  final IconData icon;
  final ResearchStatus status;

  const _PipelineStage({
    required this.label,
    required this.icon,
    required this.status,
  });
}

const _stages = [
  _PipelineStage(
    label: 'بناء الهيكل',
    icon: Icons.account_tree_outlined,
    status: ResearchStatus.outlining,
  ),
  _PipelineStage(
    label: 'جمع المصادر الأكاديمية',
    icon: Icons.search_outlined,
    status: ResearchStatus.researching,
  ),
  _PipelineStage(
    label: 'كتابة المحتوى',
    icon: Icons.edit_note_outlined,
    status: ResearchStatus.writing,
  ),
  _PipelineStage(
    label: 'مراجعة الترابط',
    icon: Icons.fact_check_outlined,
    status: ResearchStatus.reviewing,
  ),
  _PipelineStage(
    label: 'تجميع الملف',
    icon: Icons.folder_zip_outlined,
    status: ResearchStatus.assembling,
  ),
];

/// يتتبع مراحل pipeline البحث ويعرضها بشكل مرئي
class PipelineStageTracker extends StatelessWidget {
  final ResearchStatus currentStatus;

  const PipelineStageTracker({
    super.key,
    required this.currentStatus,
  });

  bool _isCompleted(ResearchStatus stageStatus) {
    final order = _stageOrder(currentStatus);
    final stageOrder = _stageOrder(stageStatus);
    return stageOrder < order;
  }

  bool _isActive(ResearchStatus stageStatus) {
    return stageStatus == currentStatus;
  }

  int _stageOrder(ResearchStatus s) {
    return switch (s) {
      ResearchStatus.outlining => 0,
      ResearchStatus.researching => 1,
      ResearchStatus.writing => 2,
      ResearchStatus.reviewing => 3,
      ResearchStatus.assembling => 4,
      ResearchStatus.completed => 5,
      _ => -1,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(kCardRadius),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: cardPadding,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            for (int i = 0; i < _stages.length; i++) ...[
              _StageStepTile(
                stage: _stages[i],
                isCompleted: _isCompleted(_stages[i].status),
                isActive: _isActive(_stages[i].status),
              ),
              if (i < _stages.length - 1)
                _StageConnector(
                  isCompleted: _isCompleted(_stages[i].status),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StageConnector extends StatelessWidget {
  final bool isCompleted;

  const _StageConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 19),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 24,
            color: isCompleted ? kPrimaryGreen : kBorderColor,
          ),
        ],
      ),
    );
  }
}

/// بلاط مرحلة واحدة
class _StageStepTile extends StatelessWidget {
  final _PipelineStage stage;
  final bool isCompleted;
  final bool isActive;

  const _StageStepTile({
    required this.stage,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isCompleted
        ? kPrimaryGreen
        : isActive
            ? kGoldAccent
            : kBorderColor;

    final Color textColor =
        isActive ? kTextPrimary : isCompleted ? kPrimaryGreen : kTextSecondary;

    return Row(
      children: [
        // Dot indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: dotColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: dotColor,
              width: isActive ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: kPrimaryGreen, size: 18)
                : isActive
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kGoldAccent,
                        ),
                      )
                    : Icon(stage.icon, color: kBorderColor, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stage.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (isActive)
                const Text(
                  'جارٍ التنفيذ الآن...',
                  style: TextStyle(
                    fontSize: 11,
                    color: kGoldAccent,
                  ),
                ),
              if (isCompleted)
                const Text(
                  'مكتمل ✓',
                  style: TextStyle(
                    fontSize: 11,
                    color: kPrimaryGreen,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
