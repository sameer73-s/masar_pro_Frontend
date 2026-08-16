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
        pending => 'في الانتظار',
        outlining => 'بناء هيكل البحث',
        researching => 'جمع المصادر الأكاديمية',
        writing => 'كتابة المحتوى',
        reviewing => 'مراجعة الترابط',
        assembling => 'تجميع الملف',
        completed => 'مكتمل ✓',
        failed => 'فشل',
        cancelled => 'تم الإيقاف',
      };

  bool get isActive =>
      this != completed &&
      this != failed &&
      this != cancelled &&
      this != pending;
  bool get isTerminal =>
      this == completed || this == failed || this == cancelled;
}
