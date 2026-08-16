import 'package:flutter/material.dart';

class ChangeTagChip extends StatelessWidget {
  final String original;
  final String replacement;
  final String category;

  const ChangeTagChip({
    super.key,
    required this.original,
    required this.replacement,
    required this.category,
  });

  Color _getCategoryColor() {
    switch (category) {
      case 'arabic_marker':
        return const Color(0xFFDCFCE7); // Light Green
      case 'vocabulary':
        return const Color(0xFFDBEAFE); // Light Blue
      case 'structure':
        return const Color(0xFFFEF9C3); // Light Yellow
      case 'filler':
        return const Color(0xFFF3E8FF); // Light Purple
      default:
        return const Color(0xFFF1F5F9); // Light Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getCategoryColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            original,
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            replacement,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
