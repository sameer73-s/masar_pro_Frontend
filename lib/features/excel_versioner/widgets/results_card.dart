import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_colors.dart';
import '../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../core/presentation/widgets/primary_button.dart';
import '../domain/entities/excel_version.dart';

class ResultsCard extends StatelessWidget {
  final List<ExcelVersion> versions;
  final String zipUrl;
  final double processingTime;
  final VoidCallback onReset;

  const ResultsCard({
    super.key,
    required this.versions,
    required this.zipUrl,
    required this.processingTime,
    required this.onReset,
  });

  Future<void> _downloadUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        AppErrorDialog.show(
          context,
          message: 'عذراً، لم نتمكن من فتح رابط التحميل.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      AppErrorDialog.show(context, message: 'خطأ أثناء فتح الرابط: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Colors.green,
          width: 1.5,
        ),
      ),
      color: Colors.green.withOpacity(0.01),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Success header icon and text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "تم إنشاء ${versions.length} نسخة بنجاح",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "زمن المعالجة: $processingTime ثانية",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.slateGray,
              ),
            ),
            const SizedBox(height: 20),
            
            // List of versions
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slateGray.withOpacity(0.1)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: versions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final version = versions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const Icon(
                      Icons.insert_drive_file,
                      color: Colors.green,
                    ),
                    title: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        version.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.download, color: AppColors.deepNavy),
                      onPressed: () => _downloadUrl(context, version.url),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // ZIP download button
            PrimaryButton(
              text: 'تحميل الكل (ZIP)',
              onPressed: () => _downloadUrl(context, zipUrl),
              icon: Icons.archive_outlined,
              width: double.infinity,
              height: 50,
            ),
            const SizedBox(height: 12),
            
            // Reset button
            OutlinedButton.icon(
              onPressed: onReset,
              icon: Icon(Icons.refresh, color: AppColors.deepNavy),
              label: Text(
                "إنشاء مجموعة جديدة",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.deepNavy),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppColors.deepNavy, width: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
