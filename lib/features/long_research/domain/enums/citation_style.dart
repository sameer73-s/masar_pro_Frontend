enum CitationStyle {
  apa,
  mla,
  chicago;

  String get apiValue => name;
  String get label => name.toUpperCase();
}
