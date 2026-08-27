import 'package:easy_localization/easy_localization.dart';

enum ResearchLanguage {
  arabic,
  english;

  String get apiValue => name;

  String get label => switch (this) {
        arabic => 'researchLanguageArabic'.tr(),
        english => 'researchLanguageEnglish'.tr(),
      };

  String get flag => switch (this) {
        arabic => '🇸🇦',
        english => '🇬🇧',
      };
}
