import '../../domain/entities/readiness_report.dart';
import '../../domain/enums/readiness_status.dart';

class ReadinessCheckItemModel extends ReadinessCheckItem {
  const ReadinessCheckItemModel({
    required super.label,
    required super.status,
    super.score,
  });

  factory ReadinessCheckItemModel.fromJson(Map<String, dynamic> json) {
    final score = _asDouble(json['score']);
    final statusRaw = json['status']?.toString();
    return ReadinessCheckItemModel(
      label: (json['label'] ?? json['name'] ?? json['check'])?.toString() ?? '',
      status: statusRaw != null && statusRaw.isNotEmpty
          ? ReadinessStatus.fromApi(statusRaw)
          : ReadinessStatus.fromScore(score ?? 0),
      score: score,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'status': status.apiValue,
      if (score != null) 'score': score,
    };
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class ReadinessReportModel extends ReadinessReport {
  const ReadinessReportModel({
    required super.overallScore,
    required super.status,
    required super.checks,
  });

  factory ReadinessReportModel.fromJson(Map<String, dynamic> json) {
    final payload = json['report'] is Map
        ? Map<String, dynamic>.from(json['report'] as Map)
        : json;
    final overall = _asDouble(
          payload['overall_score'] ?? payload['overallScore'],
        ) ??
        0;
    final checks = _parseChecks(payload, overall);

    final statusRaw = payload['status']?.toString();
    return ReadinessReportModel(
      overallScore: overall,
      status: (statusRaw != null && statusRaw.isNotEmpty)
          ? ReadinessStatus.fromApi(statusRaw)
          : ReadinessStatus.fromScore(overall),
      checks: checks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_score': overallScore,
      'status': status.apiValue,
      'checks': checks
          .map(
            (check) => check is ReadinessCheckItemModel
                ? check.toJson()
                : ReadinessCheckItemModel(
                    label: check.label,
                    status: check.status,
                    score: check.score,
                  ).toJson(),
          )
          .toList(),
    };
  }

  static List<ReadinessCheckItem> _parseChecks(
    Map<String, dynamic> payload,
    double overall,
  ) {
    final rawChecks = payload['checks'];
    if (rawChecks is List && rawChecks.isNotEmpty) {
      return rawChecks
          .whereType<Map>()
          .map(
            (item) => ReadinessCheckItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    const dimensions = <String, String>{
      'structure_score': 'Structure',
      'abstract_score': 'Abstract',
      'references_score': 'References',
      'methodology_score': 'Methodology',
      'formatting_score': 'Formatting',
    };

    final fromScores = <ReadinessCheckItem>[];
    for (final entry in dimensions.entries) {
      final score = _asDouble(payload[entry.key]);
      if (score == null) continue;
      fromScores.add(
        ReadinessCheckItemModel(
          label: entry.value,
          status: ReadinessStatus.fromScore(score),
          score: score,
        ),
      );
    }

    final issues = payload['critical_issues'] ?? payload['criticalIssues'];
    if (issues is List) {
      for (final issue in issues) {
        final label = issue?.toString() ?? '';
        if (label.isEmpty) continue;
        fromScores.add(
          ReadinessCheckItemModel(
            label: label,
            status: ReadinessStatus.blocker,
          ),
        );
      }
    }

    if (fromScores.isNotEmpty) return fromScores;

    return [
      ReadinessCheckItemModel(
        label: 'Overall readiness',
        status: ReadinessStatus.fromScore(overall),
        score: overall,
      ),
    ];
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
