import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PipelineProgressStepper extends StatelessWidget {
  final int currentStep; // 1 to 4

  const PipelineProgressStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStep('pipelineStepAnalysis'.tr(), 1),
          _buildLine(1),
          _buildStep('pipelineStepGeneration'.tr(), 2),
          _buildLine(2),
          _buildStep('pipelineStepQuality'.tr(), 3),
          _buildLine(3),
          _buildStep('pipelineStepExport'.tr(), 4),
        ],
      ),
    );
  }

  Widget _buildStep(String label, int step) {
    final isCompleted = step < currentStep;
    final isActive = step == currentStep;
    
    Color color;
    if (isCompleted) {
      color = const Color(0xFF16A34A);
    } else if (isActive) {
      color = const Color(0xFF3B82F6);
    } else {
      color = const Color(0xFFCBD5E1);
    }

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? color : Colors.white,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : isActive 
                    ? const SizedBox(
                        width: 14, 
                        height: 14, 
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)))
                      )
                    : Text('$step', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : const Color(0xFF64748B),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int step) {
    final isCompleted = step < currentStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
        margin: const EdgeInsets.only(bottom: 24, left: 4, right: 4), 
      ),
    );
  }
}
