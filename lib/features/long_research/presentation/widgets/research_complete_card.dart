import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import 'animated_progress_ring.dart';

/// بطاقة النجاح عند اكتمال البحث
class ResearchCompleteCard extends StatefulWidget {
  final int totalWords;
  final int sourcesCount;
  final int processingTimeSeconds;
  final VoidCallback onDownload;
  final VoidCallback onNewResearch;
  final bool isDownloading;

  const ResearchCompleteCard({
    super.key,
    required this.totalWords,
    required this.sourcesCount,
    required this.processingTimeSeconds,
    required this.onDownload,
    required this.onNewResearch,
    this.isDownloading = false,
  });

  @override
  State<ResearchCompleteCard> createState() => _ResearchCompleteCardState();
}

class _ResearchCompleteCardState extends State<ResearchCompleteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _minutes =>
      (widget.processingTimeSeconds ~/ 60).toString();

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(kCardRadius),
              border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryGreen.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: cardPadding,
            child: Column(
              children: [
                // Emoji + عنوان
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                const Text(
                  'اكتمل بحثك الأكاديمي!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // إحصاءات
                Row(
                  children: [
                    _StatChip(
                      value:
                          _formatNumber(widget.totalWords),
                      label: 'كلمة',
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      value: widget.sourcesCount.toString(),
                      label: 'مصدر',
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      value: _minutes,
                      label: 'دقيقة',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // زر التحميل
                PrimaryButton(
                  text: 'تحميل ملف Word',
                  onPressed: widget.isDownloading ? null : widget.onDownload,
                  isLoading: widget.isDownloading,
                  icon: Icons.download_rounded,
                  width: double.infinity,
                  height: 52,
                ),
                const SizedBox(height: 10),

                // زر بحث جديد
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: widget.onNewResearch,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kPrimaryGreen, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(kButtonRadius),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: kPrimaryGreen),
                        SizedBox(width: 6),
                        Text(
                          'بحث جديد',
                          style: TextStyle(
                            color: kPrimaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: kPrimaryGreen.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kPrimaryGreen,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
