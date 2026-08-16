enum TaskStatus {
  uploaded,
  pendingApproval,
  approved,
  rejected,
  processing,
  completed,
  failed;

  /// Maps API values (`UPLOADED`, `PENDING_APPROVAL`, …) and Dart names.
  factory TaskStatus.fromApi(String? value) {
    final normalized = (value ?? '').trim().toUpperCase().replaceAll('-', '_');
    return switch (normalized) {
      'UPLOADED' || 'ANALYZED' => TaskStatus.uploaded,
      'PENDING_APPROVAL' || 'PENDINGAPPROVAL' => TaskStatus.pendingApproval,
      'APPROVED' => TaskStatus.approved,
      'REJECTED' => TaskStatus.rejected,
      'PROCESSING' => TaskStatus.processing,
      'COMPLETED' => TaskStatus.completed,
      'FAILED' => TaskStatus.failed,
      _ => TaskStatus.uploaded,
    };
  }

  /// Wire format expected by the backend (`UPLOADED`, `PENDING_APPROVAL`, …).
  String get apiValue => switch (this) {
        TaskStatus.uploaded => 'UPLOADED',
        TaskStatus.pendingApproval => 'PENDING_APPROVAL',
        TaskStatus.approved => 'APPROVED',
        TaskStatus.rejected => 'REJECTED',
        TaskStatus.processing => 'PROCESSING',
        TaskStatus.completed => 'COMPLETED',
        TaskStatus.failed => 'FAILED',
      };
}
