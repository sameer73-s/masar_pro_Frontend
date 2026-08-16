import 'package:equatable/equatable.dart';

import '../enums/readiness_status.dart';

class ReadinessCheckItem extends Equatable {
  final String label;
  final ReadinessStatus status;
  final double? score;

  const ReadinessCheckItem({
    required this.label,
    required this.status,
    this.score,
  });

  @override
  List<Object?> get props => [label, status, score];
}

class ReadinessReport extends Equatable {
  final double overallScore;
  final ReadinessStatus status;
  final List<ReadinessCheckItem> checks;

  const ReadinessReport({
    required this.overallScore,
    required this.status,
    required this.checks,
  });

  @override
  List<Object?> get props => [overallScore, status, checks];
}
