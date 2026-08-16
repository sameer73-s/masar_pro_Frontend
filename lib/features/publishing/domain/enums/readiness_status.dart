enum ReadinessStatus {
  pass,
  warning,
  blocker;

  /// Maps API values (`PASS`, `WARNING`, `BLOCKER`) and UI aliases (`READY`).
  factory ReadinessStatus.fromApi(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    return switch (normalized) {
      'PASS' || 'READY' => ReadinessStatus.pass,
      'WARNING' => ReadinessStatus.warning,
      'BLOCKER' => ReadinessStatus.blocker,
      _ => ReadinessStatus.warning,
    };
  }

  String get apiValue => switch (this) {
        ReadinessStatus.pass => 'PASS',
        ReadinessStatus.warning => 'WARNING',
        ReadinessStatus.blocker => 'BLOCKER',
      };

  /// PUB-01 thresholds: PASS > 80, WARNING 50–80, BLOCKER < 50.
  factory ReadinessStatus.fromScore(num score) {
    if (score > 80) return ReadinessStatus.pass;
    if (score >= 50) return ReadinessStatus.warning;
    return ReadinessStatus.blocker;
  }
}
