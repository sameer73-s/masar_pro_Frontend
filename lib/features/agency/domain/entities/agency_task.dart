import 'package:equatable/equatable.dart';

import '../enums/task_status.dart';

class AgencyTask extends Equatable {
  final String id;
  final String clientId;
  final TaskStatus status;
  final String storageFolder;
  final int? quotedPrice;
  final String? aiResultRef;
  final DateTime createdAt;

  const AgencyTask({
    required this.id,
    required this.clientId,
    required this.status,
    required this.storageFolder,
    this.quotedPrice,
    this.aiResultRef,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        clientId,
        status,
        storageFolder,
        quotedPrice,
        aiResultRef,
        createdAt,
      ];
}
