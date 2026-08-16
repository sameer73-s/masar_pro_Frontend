enum ResearchLanguage {
  arabic,
  english;

  String get apiValue => name;

  String get label => switch (this) {
        arabic => 'العربية',
        english => 'English',
      };

  String get flag => switch (this) {
        arabic => '🇸🇦',
        english => '🇬🇧',
      };
}
