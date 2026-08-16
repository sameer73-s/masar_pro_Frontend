/// Live status of one parallel research worker (backend `subagent_status`).
class SubAgentStatus {
  final String id;
  final String status; // pending | running | completed | failed
  final String section;
  final String message;

  const SubAgentStatus({
    required this.id,
    required this.status,
    required this.section,
    required this.message,
  });

  bool get isRunning => status == 'running' || status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
