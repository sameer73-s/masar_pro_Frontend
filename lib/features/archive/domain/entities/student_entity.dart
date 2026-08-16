class StudentEntity {
  final String id;
  final String name;
  final String? officeName;
  final DateTime createdAt;

  const StudentEntity({
    required this.id,
    required this.name,
    this.officeName,
    required this.createdAt,
  });
}
