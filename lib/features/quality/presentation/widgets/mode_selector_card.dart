import 'package:flutter/material.dart';
import '../../domain/enums/humanize_mode.dart';

class ModeSelectorCard extends StatelessWidget {
  final HumanizeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeSelectorCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected 
        ? (mode == HumanizeMode.safe ? const Color(0xFF16A34A) : const Color(0xFF3B82F6))
        : const Color(0xFFE2E8F0);
    
    final bgColor = isSelected 
        ? (mode == HumanizeMode.safe ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF))
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  mode == HumanizeMode.safe ? Icons.shield_outlined : Icons.auto_awesome,
                  color: borderColor,
                ),
                const SizedBox(width: 8),
                Text(
                  mode.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mode.description,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
