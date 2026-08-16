class ArchivedOrderEntity {
  final String id;
  final String studentId;
  final String orderType;
  final String title;
  final String status;
  final List<String> fileUrls;
  final DateTime createdAt;

  const ArchivedOrderEntity({
    required this.id,
    required this.studentId,
    required this.orderType,
    required this.title,
    required this.status,
    required this.fileUrls,
    required this.createdAt,
  });
}
