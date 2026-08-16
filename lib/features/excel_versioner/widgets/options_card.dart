import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class OptionsCard extends StatelessWidget {
  final int versionCount;
  final bool changeStyle;
  final bool changeNumbers;
  final Function(int) onVersionCountChanged;
  final Function(bool) onStyleChanged;
  final Function(bool) onNumbersChanged;

  const OptionsCard({
    super.key,
    required this.versionCount,
    required this.changeStyle,
    required this.changeNumbers,
    required this.onVersionCountChanged,
    required this.onStyleChanged,
    required this.onNumbersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.slateGray.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: AppColors.deepNavy,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "تخصيص الخيارات",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // ── Version Count Counter ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "عدد النسخ المطلوبة",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.slateGray.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: versionCount > 2
                            ? () => onVersionCountChanged(versionCount - 1)
                            : null,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        alignment: Alignment.center,
                        child: Text(
                          "$versionCount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: versionCount < 20
                            ? () => onVersionCountChanged(versionCount + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // ── Style changes Switch ──────────────────────────────────────────
            SwitchListTile.adaptive(
              title: Text(
                "تغيير الألوان والتنسيق",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                ),
              ),
              subtitle: Text(
                "يغير الألوان وحجم ونوع الخطوط بشكل عشوائي ومميز لكل نسخة",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.slateGray,
                ),
              ),
              value: changeStyle,
              activeColor: AppColors.accentGold,
              contentPadding: EdgeInsets.zero,
              onChanged: onStyleChanged,
            ),
            const Divider(height: 16),
            
            // ── Number changes Switch ─────────────────────────────────────────
            SwitchListTile.adaptive(
              title: Text(
                "تغيير الأرقام بنسب طفيفة",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                ),
              ),
              subtitle: Text(
                "يغير القيم الرقمية عشوائياً بنسبة ±5% مع الحفاظ على الخانات العشرية والمعادلات",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.slateGray,
                ),
              ),
              value: changeNumbers,
              activeColor: AppColors.accentGold,
              contentPadding: EdgeInsets.zero,
              onChanged: onNumbersChanged,
            ),
          ],
        ),
      ),
    );
  }
}
