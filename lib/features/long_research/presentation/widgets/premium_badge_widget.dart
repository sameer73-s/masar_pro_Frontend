import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'animated_progress_ring.dart';

/// شريط علوي ذهبي يعلن عن الميزة المتميزة
class PremiumBadgeWidget extends StatelessWidget {
  const PremiumBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kGoldAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          const Text('✦', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'researchPremiumBanner'.tr(),
              textDirection: Directionality.of(context),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const _PremiumBadge(),
        ],
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'researchPremiumBadge'.tr(),
        style: const TextStyle(
          color: Color(0xFFD97706),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
