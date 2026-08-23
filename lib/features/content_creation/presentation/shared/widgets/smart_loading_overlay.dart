import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../config/app_colors.dart';

class SmartLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final String message;
  final List<String> steps;
  final int currentStepIndex;

   SmartLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.message,
    required this.steps,
    required this.currentStepIndex,
  });

  @override
  State<SmartLoadingOverlay> createState() => _SmartLoadingOverlayState();
}

class _SmartLoadingOverlayState extends State<SmartLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;

  @override
  void initState() {
    super.initState();
    // Rotation animation for the gradient ring
    _rotationController = AnimationController(
      vsync: this,
      duration:  Duration(seconds: 2),
    );

    // Pulse animation for the background aura
    _pulseController = AnimationController(
      vsync: this,
      duration:  Duration(milliseconds: 1800),
    );

    _pulseScaleAnimation = Tween<double>(begin: 0.8, end: 1.6).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _pulseOpacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isLoading) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _rotationController.repeat();
    _pulseController.repeat();
  }

  void _stopAnimations() {
    _rotationController.stop();
    _pulseController.stop();
  }

  @override
  void didUpdateWidget(covariant SmartLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _startAnimations();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return  SizedBox.shrink();

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.black.withOpacity(0.70),
          child: SafeArea(
            child: Column(
              children: [
                 Spacer(flex: 3),
                // Premium Rotating Gradient Ring & Pulse
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Inner Pulsing Wave Aura
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _pulseOpacityAnimation.value,
                            child: Transform.scale(
                              scale: _pulseScaleAnimation.value,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accentGold.withOpacity(0.25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentGold.withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Rotating Gradient Ring
                      RotationTransition(
                        turns: _rotationController,
                        child: CustomPaint(
                          size:  Size(120, 120),
                          painter: GradientRingPainter(
                            gradientColor: AppColors.accentGold,
                          ),
                        ),
                      ),
                      // Glowing Center Core with Icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.deepNavy,
                          border: Border.all(
                            color: AppColors.accentGold.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child:  Icon(
                          Icons.auto_awesome,
                          color: AppColors.accentGold,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                 SizedBox(height: 40),
                // Smooth Text Messages (Slide + Fade)
                //app[ud]
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration:  Duration(milliseconds: 550),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin:  Offset(0.0, 0.35),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        widget.message,
                        key: ValueKey<String>(widget.message),
                        textAlign: TextAlign.center,
                        style:  TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                 Spacer(flex: 2),
                // Timeline Step Indicator
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildStepTimeline(),
                ),
                 SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepTimeline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.steps.length, (index) {
        final isCompleted = index < widget.currentStepIndex;
        final isActive = index == widget.currentStepIndex;

        Color dotColor;
        Color textColor;
        double dotSize = isActive ? 28 : 22;

        if (isCompleted) {
          dotColor = AppColors.accentGold;
          textColor = Colors.white70;
        } else if (isActive) {
          dotColor = AppColors.accentGold;
          textColor = Colors.white;
        } else {
          dotColor = AppColors.slateGray.withOpacity(0.4);
          textColor = Colors.white38;
        }

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Leading connector line
                  Expanded(
                    child: Container(
                      height: 2.5,
                      color: index == 0
                          ? Colors.transparent
                          : (index <= widget.currentStepIndex
                              ? AppColors.accentGold
                              : AppColors.slateGray.withOpacity(0.3)),
                    ),
                  ),
                  // Step Node
                  AnimatedContainer(
                    duration:  Duration(milliseconds: 300),
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? dotColor : AppColors.deepNavy,
                      border: Border.all(
                        color: dotColor,
                        width: isActive ? 3 : 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.accentGold.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ?  Icon(
                              Icons.check,
                              size: 13,
                              color: AppColors.deepNavy,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? AppColors.accentGold : Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  // Trailing connector line
                  Expanded(
                    child: Container(
                      height: 2.5,
                      color: index == widget.steps.length - 1
                          ? Colors.transparent
                          : (index < widget.currentStepIndex
                              ? AppColors.accentGold
                              : AppColors.slateGray.withOpacity(0.3)),
                    ),
                  ),
                ],
              ),
               SizedBox(height: 10),
              // Step Title
              Text(
                widget.steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: isActive ? 12.5 : 11.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// Custom Painter for the beautiful Sweep Gradient Ring
class GradientRingPainter extends CustomPainter {
  final Color gradientColor;

  GradientRingPainter({required this.gradientColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 5.0;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          gradientColor.withOpacity(0.0),
          gradientColor.withOpacity(0.2),
          gradientColor.withOpacity(0.6),
          gradientColor,
        ],
        stops:  [0.0, 0.25, 0.7, 1.0],
      ).createShader(rect);

    // Draw the gradient arc
    canvas.drawArc(rect, 0, 3.14 * 2 * 0.95, false, paint);
  }

  @override
  bool shouldRepaint(covariant GradientRingPainter oldDelegate) {
    return oldDelegate.gradientColor != gradientColor;
  }
}
