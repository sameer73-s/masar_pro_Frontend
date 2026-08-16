import '../../domain/entities/journal_match.dart';

class JournalMatchModel extends JournalMatch {
  const JournalMatchModel({
    required super.journalId,
    required super.journalName,
    required super.quartile,
    required super.apc,
    required super.matchScore,
  });

  factory JournalMatchModel.fromJson(Map<String, dynamic> json) {
    return JournalMatchModel(
      journalId: (json['journal_id'] ?? json['journalId'])?.toString() ?? '',
      journalName:
          (json['journal_name'] ?? json['journalName'] ?? json['name'])
              ?.toString() ??
          '',
      quartile: json['quartile']?.toString() ?? '',
      apc: _asDouble(json['apc'] ?? json['apc_price'] ?? json['apcPrice']),
      matchScore: _asDouble(
        json['match_score'] ?? json['matchScore'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'journal_id': journalId,
      'journal_name': journalName,
      'name': journalName,
      'quartile': quartile,
      'apc': apc,
      'match_score': matchScore,
    };
  }

  factory JournalMatchModel.fromEntity(JournalMatch entity) {
    return JournalMatchModel(
      journalId: entity.journalId,
      journalName: entity.journalName,
      quartile: entity.quartile,
      apc: entity.apc,
      matchScore: entity.matchScore,
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
