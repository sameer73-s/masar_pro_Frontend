import 'package:flutter/material.dart';

class ScoreRingWidget extends StatelessWidget {
  final double score;
  final String label;

  const ScoreRingWidget({
    super.key,
    required this.score,
    required this.label,
  });

  Color _getColor(double value) {
    if (value > 50) return const Color(0xFFDC2626); // Red
    if (value > 25) return const Color(0xFFD97706); // Orange
    return const Color(0xFF16A34A); // Green
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(score);
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: score / 100.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 6,
                  );
                },
              ),
              Center(
                child: Text(
                  score.toInt().toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }
}
