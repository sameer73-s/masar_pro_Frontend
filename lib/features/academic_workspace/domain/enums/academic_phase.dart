/// Journey phases for an academic project (matches backend `AcademicPhase`).
enum AcademicPhase {
  proposal,
  research,
  publishing;

  /// Wire format expected by the backend (`proposal`, `research`, `publishing`).
  String get apiValue => name;

  factory AcademicPhase.fromApi(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return switch (normalized) {
      'proposal' => AcademicPhase.proposal,
      'research' => AcademicPhase.research,
      'publishing' => AcademicPhase.publishing,
      _ => AcademicPhase.proposal,
    };
  }
}
