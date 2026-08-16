import '../../domain/entities/agency_task.dart';
import '../../domain/enums/task_status.dart';

class AgencyTaskModel extends AgencyTask {
  const AgencyTaskModel({
    required super.id,
    required super.clientId,
    required super.status,
    required super.storageFolder,
    super.quotedPrice,
    super.aiResultRef,
    required super.createdAt,
  });

  factory AgencyTaskModel.fromJson(Map<String, dynamic> json) {
    return AgencyTaskModel(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      status: TaskStatus.fromApi(json['status']?.toString()),
      storageFolder: json['storage_folder']?.toString() ?? '',
      quotedPrice: _parseInt(json['quoted_price']),
      aiResultRef: json['ai_result_ref']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'status': status.apiValue,
      'storage_folder': storageFolder,
      'quoted_price': quotedPrice,
      'ai_result_ref': aiResultRef,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory AgencyTaskModel.fromEntity(AgencyTask entity) {
    return AgencyTaskModel(
      id: entity.id,
      clientId: entity.clientId,
      status: entity.status,
      storageFolder: entity.storageFolder,
      quotedPrice: entity.quotedPrice,
      aiResultRef: entity.aiResultRef,
      createdAt: entity.createdAt,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
