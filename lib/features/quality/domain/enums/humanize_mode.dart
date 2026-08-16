enum HumanizeMode {
  safe,
  standard;

  String get apiValue => name;
  String get label => this == safe ? 'آمن' : 'متوازن';
  String get description => this == safe
      ? 'تحسين الأسلوب وإزالة العبارات المصطنعة'
      : 'أنسنة واسعة مع تنويع البنية وإيقاع الجمل';
}
