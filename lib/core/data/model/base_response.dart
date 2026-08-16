class BaseResponse<T> {
  final T? data;
  final int? code;
  final String? message;

  const BaseResponse({this.data, this.code, this.message});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return BaseResponse<T>(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      code: json['code'] as int?,
      message: json['message'] as String?,
    );
  }
}
