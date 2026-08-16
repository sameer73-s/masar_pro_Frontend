abstract final class JsonHelper {
  const JsonHelper._();
  static String str(
    Map<String, dynamic> j,
    String k, {
    String defaultValue = '',
  }) {
    final v = j[k];
    if (v == null || v.toString().trim().isEmpty) return defaultValue;
    return v.toString();
  }

  static String? strN(Map<String, dynamic> j, String k) {
    final v = j[k];
    if (v == null) return null;
    return v.toString();
  }

  static List<T> listMap<T>(dynamic v, T Function(Map<String, dynamic> m) f) {
    if (v is! List) return <T>[];
    return v.map((e) {
      if (e is Map) {
        return f(Map<String, dynamic>.from(e));
      }
      return f(<String, dynamic>{});
    }).toList();
  }

  static Map<String, dynamic> map(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    return <String, dynamic>{};
  }
}
