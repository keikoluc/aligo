/// Thrown when the Aligo backend returns an error response or the
/// request otherwise fails to complete.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
