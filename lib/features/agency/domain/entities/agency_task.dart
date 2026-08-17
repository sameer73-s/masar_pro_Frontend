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

  /// Backend `progress_pct` (integer 0–100).
  final int progressPct;

  const AgencyTask({
    required this.id,
    required this.clientId,
    required this.status,
    required this.storageFolder,
    this.quotedPrice,
    this.aiResultRef,
    required this.createdAt,
    this.progressPct = 0,
  });

  /// 0.0–1.0 for circular progress indicators (`progress_pct` / 100).
  double get progress => progressPct.clamp(0, 100) / 100.0;

  @override
  List<Object?> get props => [
        id,
        clientId,
        status,
        storageFolder,
        quotedPrice,
        aiResultRef,
        createdAt,
        progressPct,
      ];
}
