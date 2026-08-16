class PaginationResponse<T> {
  final List<T> data;
  final int? code;
  final String? message;
  final int? currentPage;
  final int? lastPage;
  final String? nextPageUrl;
  final int? perPage;
  final int? total;

  const PaginationResponse({
    required this.data,
    this.code,
    this.message,
    this.currentPage,
    this.lastPage,
    this.nextPageUrl,
    this.perPage,
    this.total,
  });

  bool get hasNextPage => nextPageUrl != null && nextPageUrl!.isNotEmpty;

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final rawData = json['data'];
    final items = rawData is List
        ? rawData.map((e) => itemFromJson(e as Map<String, dynamic>)).toList()
        : <T>[];

    return PaginationResponse<T>(
      data: items,
      code: json['code'] as int?,
      message: json['message'] as String?,
      currentPage: json['current_page'] as int?,
      lastPage: json['last_page'] as int?,
      nextPageUrl: json['next_page_url'] as String?,
      perPage: _parseInt(json['per_page']),
      total: _parseInt(json['total']),
    );
  }

  static int? _parseInt(dynamic value) =>
      value == null ? null : int.tryParse(value.toString());
}
