import 'package:hive/hive.dart';
import '../../domain/entities/archived_order_entity.dart';

part 'archived_order_model.g.dart';

@HiveType(typeId: 21)
class ArchivedOrderModel extends ArchivedOrderEntity {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String studentId;

  @override
  @HiveField(2)
  final String orderType;

  @override
  @HiveField(3)
  final String title;

  @override
  @HiveField(4)
  final String status;

  @override
  @HiveField(5)
  final List<String> fileUrls;

  @override
  @HiveField(6)
  final DateTime createdAt;

  ArchivedOrderModel({
    required this.id,
    required this.studentId,
    required this.orderType,
    required this.title,
    required this.status,
    required this.fileUrls,
    required this.createdAt,
  }) : super(
          id: id,
          studentId: studentId,
          orderType: orderType,
          title: title,
          status: status,
          fileUrls: fileUrls,
          createdAt: createdAt,
        );

  factory ArchivedOrderModel.fromEntity(ArchivedOrderEntity entity) {
    return ArchivedOrderModel(
      id: entity.id,
      studentId: entity.studentId,
      orderType: entity.orderType,
      title: entity.title,
      status: entity.status,
      fileUrls: entity.fileUrls,
      createdAt: entity.createdAt,
    );
  }
}
