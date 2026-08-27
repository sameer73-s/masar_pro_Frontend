import 'package:flutter/material.dart';
import 'animated_progress_ring.dart';

/// بطاقة نموذج البحث (معلومات أساسية أو خيارات متقدمة)
class ResearchFormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool collapsible;

  const ResearchFormCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.collapsible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(kCardRadius),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: collapsible
          ? Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                textColor: kTextPrimary,
                iconColor: kGoldAccent,
                collapsedIconColor: kTextSecondary,
                tilePadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                leading: Icon(icon, color: kGoldAccent, size: 22),
                title: Text(
                  title,
                  textDirection: Directionality.of(context),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                children: [child],
              ),
            )
          : Padding(
              padding: cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    textDirection: Directionality.of(context),
                    children: [
                      Icon(icon, color: kGoldAccent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
    );
  }
}
