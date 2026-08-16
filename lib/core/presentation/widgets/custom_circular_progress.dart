import 'package:flutter/material.dart';

/// Circular progress with a centered percentage label.
class CustomCircularProgress extends StatelessWidget {
  const CustomCircularProgress({
    super.key,
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.size = 42,
    this.strokeWidth = 6,
    this.textColor,
    this.textSize = 11,
  });

  /// Value from 0.0 to 1.0.
  final double progress;
  final double size;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  /// Defaults to [progressColor] when null.
  final Color? textColor;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final percent = (clamped * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: strokeWidth,
              backgroundColor: trackColor,
              color: progressColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w600,
              color: textColor ?? progressColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
