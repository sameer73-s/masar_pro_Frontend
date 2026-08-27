import 'package:easy_localization/easy_localization.dart';

enum ResearchStatus {
  pending,
  outlining,
  researching,
  writing,
  reviewing,
  assembling,
  completed,
  failed,
  cancelled;

  factory ResearchStatus.fromApi(String v) =>
      ResearchStatus.values.firstWhere((e) => e.name == v,
          orElse: () => ResearchStatus.pending);

  String get label => switch (this) {
        pending => 'researchStatusPending'.tr(),
        outlining => 'researchStatusOutlining'.tr(),
        researching => 'researchStatusResearching'.tr(),
        writing => 'researchStatusWriting'.tr(),
        reviewing => 'researchStatusReviewing'.tr(),
        assembling => 'researchStatusAssembling'.tr(),
        completed => 'researchStatusCompleted'.tr(),
        failed => 'researchStatusFailed'.tr(),
        cancelled => 'researchStatusCancelled'.tr(),
      };

  bool get isActive =>
      this != completed &&
      this != failed &&
      this != cancelled &&
      this != pending;
  bool get isTerminal =>
      this == completed || this == failed || this == cancelled;
}
