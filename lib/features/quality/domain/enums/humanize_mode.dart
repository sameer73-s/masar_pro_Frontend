import 'package:easy_localization/easy_localization.dart';

enum HumanizeMode {
  safe,
  standard;

  String get apiValue => name;
  String get label =>
      this == safe ? 'humanizeModeSafe'.tr() : 'humanizeModeStandard'.tr();
  String get description => this == safe
      ? 'humanizeModeSafeDesc'.tr()
      : 'humanizeModeStandardDesc'.tr();
}
