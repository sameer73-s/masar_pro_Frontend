import 'package:hive/hive.dart';
import '../../domain/entities/student_entity.dart';

part 'student_model.g.dart';

@HiveType(typeId: 20)
class StudentModel extends StudentEntity {
  @override
  @HiveField(0)
  final String id;
  
  @override
  @HiveField(1)
  final String name;
  
  @override
  @HiveField(2)
  final String? officeName;
  
  @override
  @HiveField(3)
  final DateTime createdAt;

  StudentModel({
    required this.id,
    required this.name,
    this.officeName,
    required this.createdAt,
  }) : super(
          id: id,
          name: name,
          officeName: officeName,
          createdAt: createdAt,
        );

  factory StudentModel.fromEntity(StudentEntity entity) {
    return StudentModel(
      id: entity.id,
      name: entity.name,
      officeName: entity.officeName,
      createdAt: entity.createdAt,
    );
  }
}
