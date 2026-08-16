import 'package:flutter/material.dart';
import '../../domain/entities/research_job.dart';
import 'animated_progress_ring.dart';

/// بلاط بحث سابق من Hive
class PreviousResearchTile extends StatelessWidget {
  final ResearchJob job;
  final VoidCallback? onDownload;
  final VoidCallback? onTap;

  const PreviousResearchTile({
    super.key,
    required this.job,
    this.onDownload,
    this.onTap,
  });

  String _formatDate(DateTime dt) {
    final months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final titleShort = job.title.length > 50
        ? '${job.title.substring(0, 50)}...'
        : job.title;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kCardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(color: kBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // أيقونة
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kResearchBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: kGoldAccent.withOpacity(0.3)),
              ),
              child: const Center(
                child: Icon(
                  Icons.description_outlined,
                  color: kGoldAccent,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // التفاصيل
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    titleShort,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        _formatDate(job.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // زر التحميل
            if (onDownload != null && job.downloadUrl.isNotEmpty)
              IconButton(
                onPressed: onDownload,
                icon: const Icon(
                  Icons.download_outlined,
                  color: kGoldAccent,
                ),
                tooltip: 'تحميل',
              ),
          ],
        ),
      ),
    );
  }
}
