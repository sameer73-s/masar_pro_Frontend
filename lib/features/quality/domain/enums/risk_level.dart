import 'package:flutter/material.dart';

enum RiskLevel {
  low,
  medium,
  high;

  factory RiskLevel.fromApi(String value) => switch (value) {
        'low' => low,
        'medium' => medium,
        _ => high,
      };

  String get label => switch (this) {
        low => 'منخفضة',
        medium => 'متوسطة',
        high => 'عالية',
      };

  Color get color => switch (this) {
        low => const Color(0xFF16A34A),
        medium => const Color(0xFFD97706),
        high => const Color(0xFFDC2626),
      };
}
