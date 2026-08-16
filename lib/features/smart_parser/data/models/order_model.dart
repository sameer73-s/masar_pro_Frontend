import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/dynamic_field_entity.dart';
import 'dynamic_field_model.dart';

part 'order_model.g.dart';

@HiveType(typeId: 0)
class OrderModel extends OrderEntity {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String subject;
  @override
  @HiveField(2)
  final String taskType;
  @override
  @HiveField(3)
  final DateTime deadline;
  @override
  @HiveField(4)
  final String status;
  @override
  @HiveField(5)
  final List<String> attachments;
  @override
  @HiveField(6)
  final String? missingInfo;
  @override
  @HiveField(7)
  final String? taskNameAr;
  @override
  @HiveField(8, defaultValue: true)
  final bool isReady;

  // NOTE: dynamicMissingFields is NOT persisted in Hive (it is session-only data
  // from the backend). It lives only in memory.
  @override
  final List<DynamicFieldEntity>? dynamicMissingFields;

  @override
  final String? generatedContentUrl;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? userId;

  const OrderModel({
    required this.id,
    required this.subject,
    required this.taskType,
    required this.deadline,
    required this.status,
    required this.attachments,
    this.missingInfo,
    this.taskNameAr,
    this.isReady = true,
    this.dynamicMissingFields,
    this.generatedContentUrl,
    this.createdAt,
    this.updatedAt,
    this.userId,
  }) : super(
          id: id,
          subject: subject,
          taskType: taskType,
          deadline: deadline,
          status: status,
          attachments: attachments,
          missingInfo: missingInfo,
          taskNameAr: taskNameAr,
          isReady: isReady,
          dynamicMissingFields: dynamicMissingFields,
          generatedContentUrl: generatedContentUrl,
          createdAt: createdAt,
          updatedAt: updatedAt,
          userId: userId,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse missing_info — treat "لا يوجد" as null
    final rawMissingInfo = json['missing_info']?.toString();
    final missingInfo = (rawMissingInfo != null &&
            rawMissingInfo.isNotEmpty &&
            rawMissingInfo != 'لا يوجد')
        ? rawMissingInfo
        : null;

    // Parse dynamic_missing_fields list
    List<DynamicFieldEntity>? dynamicFields;
    final rawFields = json['dynamic_missing_fields'];
    if (rawFields is List && rawFields.isNotEmpty) {
      dynamicFields = rawFields
          .whereType<Map<String, dynamic>>()
          .map((f) => DynamicFieldModel.fromJson(f))
          .toList();
    }

    // is_ready defaults to true when no dynamic fields are present
    final isReady = json['is_ready'] == true ||
        (json['is_ready'] == null && (dynamicFields == null || dynamicFields.isEmpty));

    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? 'بدون عنوان',
      taskType:
          json['task_type']?.toString() ?? json['taskType']?.toString() ?? 'غير محدد',
      deadline: json['deadline'] != null
          ? parseTimestamp(json['deadline'])
          : DateTime.now(),
      status: json['status']?.toString() ?? 'قيد المعالجة',
      attachments: List<String>.from(json['attachments'] ?? []),
      missingInfo: missingInfo,
      taskNameAr: json['task_name_ar']?.toString(),
      isReady: isReady,
      dynamicMissingFields: dynamicFields,
      generatedContentUrl: json['generated_content_url']?.toString(),
      createdAt: json['created_at'] != null ? parseTimestamp(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? parseTimestamp(json['updated_at']) : null,
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'task_type': taskType,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'attachments': attachments,
      'missing_info': missingInfo,
      'task_name_ar': taskNameAr,
      'is_ready': isReady,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'subject': subject,
      'task_type': taskType,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'attachments': attachments,
      'missing_info': missingInfo,
      'task_name_ar': taskNameAr,
      'is_ready': isReady,
      'dynamic_missing_fields': dynamicMissingFields?.map((f) {
        String fieldType;
        if (f.inputType == DynamicInputType.number) {
          fieldType = 'number';
        } else if (f.inputType == DynamicInputType.dropdown) {
          fieldType = 'select';
        } else {
          fieldType = 'text';
        }
        return {
          'field_name': f.fieldId,
          'label_ar': f.label,
          'field_type': fieldType,
          'options': f.options,
          'value': f.value,
        };
      }).toList(),
      'generated_content_url': generatedContentUrl,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': userId,
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final rawFields = data['dynamic_missing_fields'];
    List<DynamicFieldEntity>? dynamicFields;
    if (rawFields is List) {
      dynamicFields = rawFields.map((f) {
        final map = f as Map<String, dynamic>? ?? {};
        final fieldType = map['field_type']?.toString();
        DynamicInputType inputType;
        if (fieldType == 'number') {
          inputType = DynamicInputType.number;
        } else if (fieldType == 'select' || fieldType == 'dropdown') {
          inputType = DynamicInputType.dropdown;
        } else {
          inputType = DynamicInputType.text;
        }
        return DynamicFieldModel(
          fieldId: map['field_name']?.toString() ?? '',
          label: map['label_ar']?.toString() ?? '',
          inputType: inputType,
          options: List<String>.from(map['options'] ?? []),
          isMandatory: map['is_mandatory'] == true,
          value: map['value'],
        );
      }).toList();
    }

    return OrderModel(
      id: doc.id,
      subject: data['subject']?.toString() ?? 'بدون عنوان',
      taskType: data['task_type']?.toString() ?? 'غير محدد',
      deadline: data['deadline'] != null ? parseTimestamp(data['deadline']) : DateTime.now(),
      status: data['status']?.toString() ?? 'pending',
      attachments: List<String>.from(data['attachments'] ?? []),
      missingInfo: data['missing_info']?.toString(),
      taskNameAr: data['task_name_ar']?.toString(),
      isReady: data['is_ready'] == true,
      dynamicMissingFields: dynamicFields,
      generatedContentUrl: data['generated_content_url']?.toString(),
      createdAt: data['created_at'] != null ? parseTimestamp(data['created_at']) : null,
      updatedAt: data['updated_at'] != null ? parseTimestamp(data['updated_at']) : null,
      userId: data['user_id']?.toString(),
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      subject: entity.subject,
      taskType: entity.taskType,
      deadline: entity.deadline,
      status: entity.status,
      attachments: entity.attachments,
      missingInfo: entity.missingInfo,
      taskNameAr: entity.taskNameAr,
      isReady: entity.isReady,
      dynamicMissingFields: entity.dynamicMissingFields,
      generatedContentUrl: entity.generatedContentUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
    );
  }
}
