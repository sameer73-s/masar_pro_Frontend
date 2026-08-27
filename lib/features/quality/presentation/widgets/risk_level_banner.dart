import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../domain/enums/risk_level.dart';

class RiskLevelBanner extends StatelessWidget {
  final RiskLevel riskLevel;
  final int overallSimilarity;
  final int flaggedSentences;
  final int totalSentences;

  const RiskLevelBanner({
    super.key,
    required this.riskLevel,
    required this.overallSimilarity,
    required this.flaggedSentences,
    required this.totalSentences,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (riskLevel == RiskLevel.low) {
      bgColor = const Color(0xFFF0FDF4);
    } else if (riskLevel == RiskLevel.medium) {
      bgColor = const Color(0xFFFEF3C7);
    } else {
      bgColor = const Color(0xFFFEF2F2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskLevel.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            riskLevel == RiskLevel.low ? Icons.check_circle : Icons.warning_amber_rounded,
            color: riskLevel.color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'riskLevelTitle'.tr(args: [riskLevel.label]),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: riskLevel.color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'riskBannerStats'.tr(args: [
                    '$overallSimilarity',
                    '$flaggedSentences',
                    '$totalSentences',
                  ]),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
