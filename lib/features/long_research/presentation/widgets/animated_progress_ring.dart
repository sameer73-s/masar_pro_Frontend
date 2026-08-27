import 'dart:math' as math;
import 'package:flutter/material.dart';

const Color kGoldAccent = Color(0xFFF59E0B);
const Color kPrimaryGreen = Color(0xFF1D9E75);
const Color kPrimaryBlue = Color(0xFF185FA5);
const Color kBgLight = Color(0xFFF8FAFC);
const Color kCardBg = Colors.white;
const Color kTextPrimary = Color(0xFF0F172A);
const Color kTextSecondary = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kResearchGold = Color(0xFFF59E0B);
const Color kResearchBg = Color(0xFFFFFBEB);

const double kCardRadius = 14;
const double kButtonRadius = 14;
const double kChipRadius = 20;

const pagePadding =
    EdgeInsets.symmetric(horizontal: 16, vertical: 20);
const cardPadding = EdgeInsets.all(18);
const sectionGap = SizedBox(height: 16);

/// دائرة التقدم المتحركة المخصصة
class AnimatedProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final String? centerLabel;
  final String? subLabel;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.isCompleted = false,
    this.centerLabel,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = isCompleted ? kPrimaryGreen : kGoldAccent;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, animatedValue, _) {
        return SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _ProgressRingPainter(
              progress: animatedValue,
              ringColor: ringColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      '${(animatedValue * 100).toInt()}%',
                      key: ValueKey((animatedValue * 100).toInt()),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (subLabel != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        subLabel!,
                        textAlign: TextAlign.center,
                        textDirection: Directionality.of(context),
                        style: const TextStyle(
                          fontSize: 11,
                          color: kTextSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;

  _ProgressRingPainter({required this.progress, required this.ringColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    // Background ring
    final bgPaint = Paint()
      ..color = kBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = ringColor.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ringColor != ringColor;
}
