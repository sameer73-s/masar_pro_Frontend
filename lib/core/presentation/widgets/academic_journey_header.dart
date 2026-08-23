import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

/// Visual state for a single academic journey stage.
enum AcademicJourneyStageState {
  approved,
  active,
  locked,
}

/// Horizontal 3-stage journey: Proposal → Full Research → Publishing.
class AcademicJourneyHeader extends StatelessWidget {
  const AcademicJourneyHeader({
    super.key,
    required this.proposalStatus,
    required this.researchStatus,
    required this.publishingStatus,
  });

  final String proposalStatus;
  final String researchStatus;
  final String publishingStatus;

  static AcademicJourneyStageState stageStateForProposal(String status) {
    final s = status.trim().toUpperCase();
    if (s == 'APPROVED') return AcademicJourneyStageState.approved;
    if (s == 'NOT_STARTED') return AcademicJourneyStageState.locked;
    return AcademicJourneyStageState.active;
  }

  static AcademicJourneyStageState stageStateForResearch(
    String status, {
    required String proposalStatus,
  }) {
    final s = status.trim().toUpperCase();
    if (s == 'APPROVED') return AcademicJourneyStageState.approved;
    if (s == 'NOT_STARTED') {
      return proposalStatus.trim().toUpperCase() == 'APPROVED'
          ? AcademicJourneyStageState.active
          : AcademicJourneyStageState.locked;
    }
    return AcademicJourneyStageState.active;
  }

  static AcademicJourneyStageState stageStateForPublishing(
    String status, {
    required String researchStatus,
  }) {
    final s = status.trim().toUpperCase();
    if (s == 'COMPLETED') return AcademicJourneyStageState.approved;
    if (s == 'NOT_STARTED') {
      return researchStatus.trim().toUpperCase() == 'APPROVED'
          ? AcademicJourneyStageState.active
          : AcademicJourneyStageState.locked;
    }
    return AcademicJourneyStageState.active;
  }

  @override
  Widget build(BuildContext context) {
    final stages = [
      (
        icon: '📋',
        label: 'Proposal',
        state: stageStateForProposal(proposalStatus),
      ),
      (
        icon: '📚',
        label: 'Full Research',
        state: stageStateForResearch(
          researchStatus,
          proposalStatus: proposalStatus,
        ),
      ),
      (
        icon: '📖',
        label: 'Publishing',
        state: stageStateForPublishing(
          publishingStatus,
          researchStatus: researchStatus,
        ),
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: _JourneyConnector(
                  completed:
                      stages[i - 1].state == AcademicJourneyStageState.approved,
                ),
              ),
            ),
          _JourneyStageNode(
            icon: stages[i].icon,
            label: stages[i].label,
            state: stages[i].state,
          ),
        ],
      ],
    );
  }
}

class _JourneyConnector extends StatelessWidget {
  const _JourneyConnector({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: completed ? AppColors.accentPurple : const Color(0xFFC5C0D3),
    );
  }
}

class _JourneyStageNode extends StatelessWidget {
  const _JourneyStageNode({
    required this.icon,
    required this.label,
    required this.state,
  });

  final String icon;
  final String label;
  final AcademicJourneyStageState state;

  @override
  Widget build(BuildContext context) {
    final isApproved = state == AcademicJourneyStageState.approved;
    final isActive = state == AcademicJourneyStageState.active;
    final isLocked = state == AcademicJourneyStageState.locked;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isApproved
                        ? AppColors.greenLight
                        : isActive
                            ? AppColors.surfacePurple
                            : AppColors.grayLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isApproved
                          ? AppColors.success
                          : isActive
                              ? AppColors.accentPurple
                              : const Color(0xFFC5C0D3),
                      width: 1.5,
                    ),
                  ),
                  child: isApproved
                      ? Icon(
                          Icons.check_rounded,
                          size: 22,
                          color: AppColors.success,
                        )
                      : Text(
                          isLocked ? '🔒' : icon,
                          style: TextStyle(
                            fontSize: isLocked ? 16 : 18,
                            color: isLocked
                                ? AppColors.textSecondary
                                : AppColors.accentPurple,
                          ),
                        ),
                ),
                if (isActive)
                  const Positioned(
                    right: -1,
                    top: -1,
                    child: _PulsingDot(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              height: 1.15,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isApproved || isActive
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.accentPurple,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: 1.5),
          ),
        ),
      ),
    );
  }
}
