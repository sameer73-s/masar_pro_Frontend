enum ResearchProjectStatus {
  draft,
  analyzing,
  readyForJournal,
  needsRevision,
  submitted,
  accepted,
  rejected;

  /// Maps API values (`DRAFT`, `READY_FOR_JOURNAL`, …) and Dart names.
  factory ResearchProjectStatus.fromApi(String? value) {
    final normalized = (value ?? '').trim().toUpperCase().replaceAll('-', '_');
    return switch (normalized) {
      'DRAFT' => ResearchProjectStatus.draft,
      'ANALYZING' => ResearchProjectStatus.analyzing,
      'READY_FOR_JOURNAL' || 'READYFORJOURNAL' =>
        ResearchProjectStatus.readyForJournal,
      'NEEDS_REVISION' || 'NEEDSREVISION' =>
        ResearchProjectStatus.needsRevision,
      'SUBMITTED' => ResearchProjectStatus.submitted,
      'ACCEPTED' => ResearchProjectStatus.accepted,
      'REJECTED' => ResearchProjectStatus.rejected,
      _ => ResearchProjectStatus.draft,
    };
  }

  String get apiValue => switch (this) {
        ResearchProjectStatus.draft => 'DRAFT',
        ResearchProjectStatus.analyzing => 'ANALYZING',
        ResearchProjectStatus.readyForJournal => 'READY_FOR_JOURNAL',
        ResearchProjectStatus.needsRevision => 'NEEDS_REVISION',
        ResearchProjectStatus.submitted => 'SUBMITTED',
        ResearchProjectStatus.accepted => 'ACCEPTED',
        ResearchProjectStatus.rejected => 'REJECTED',
      };
}
