import 'package:equatable/equatable.dart';
import 'dynamic_field_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String subject;
  final String taskType;
  final DateTime deadline;
  final String status;
  final List<String> attachments;
  final String? missingInfo;

  /// Arabic task name returned by the backend blueprint.
  final String? taskNameAr;

  /// Dynamic fields the backend expects the user to fill in.
  final List<DynamicFieldEntity>? dynamicMissingFields;

  /// `true` when the order has enough info to generate content immediately.
  final bool isReady;

  final String? generatedContentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;

  const OrderEntity({
    required this.id,
    required this.subject,
    required this.taskType,
    required this.deadline,
    required this.status,
    required this.attachments,
    this.missingInfo,
    this.taskNameAr,
    this.dynamicMissingFields,
    this.isReady = true,
    this.generatedContentUrl,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  @override
  List<Object?> get props => [
        id,
        subject,
        taskType,
        deadline,
        status,
        attachments,
        missingInfo,
        taskNameAr,
        dynamicMissingFields,
        isReady,
        generatedContentUrl,
        createdAt,
        updatedAt,
        userId,
      ];
}
