class ApiResult<T> {
  final int httpCode;
  final T? data;
  final String? message;

  ApiResult({required this.httpCode, this.data, this.message});
  bool get isSuccess => httpCode >= 200 && httpCode < 300;
}
