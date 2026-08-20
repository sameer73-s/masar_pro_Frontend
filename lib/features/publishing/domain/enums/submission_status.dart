enum SubmissionStatus {
  submitted,
  withEditor,
  underReview,
  revisionRequired,
  resubmitted,
  accepted,
  rejected;

  factory SubmissionStatus.fromApi(String? value) {
    final normalized = (value ?? '').trim().toUpperCase().replaceAll('-', '_');
    return switch (normalized) {
      'SUBMITTED' => SubmissionStatus.submitted,
      'WITH_EDITOR' || 'WITHEDITOR' => SubmissionStatus.withEditor,
      'UNDER_REVIEW' || 'UNDERREVIEW' => SubmissionStatus.underReview,
      'REVISION_REQUIRED' || 'REVISIONREQUIRED' =>
        SubmissionStatus.revisionRequired,
      'RESUBMITTED' => SubmissionStatus.resubmitted,
      'ACCEPTED' => SubmissionStatus.accepted,
      'REJECTED' => SubmissionStatus.rejected,
      _ => SubmissionStatus.submitted,
    };
  }

  String get apiValue => switch (this) {
        SubmissionStatus.submitted => 'SUBMITTED',
        SubmissionStatus.withEditor => 'WITH_EDITOR',
        SubmissionStatus.underReview => 'UNDER_REVIEW',
        SubmissionStatus.revisionRequired => 'REVISION_REQUIRED',
        SubmissionStatus.resubmitted => 'RESUBMITTED',
        SubmissionStatus.accepted => 'ACCEPTED',
        SubmissionStatus.rejected => 'REJECTED',
      };

  String get label => switch (this) {
        SubmissionStatus.submitted => 'Submitted',
        SubmissionStatus.withEditor => 'With Editor',
        SubmissionStatus.underReview => 'Under Review',
        SubmissionStatus.revisionRequired => 'Revision Required',
        SubmissionStatus.resubmitted => 'Resubmitted',
        SubmissionStatus.accepted => 'Accepted',
        SubmissionStatus.rejected => 'Rejected',
      };
}
