/// Thrown when the Aligo backend returns an error response or the
/// request otherwise fails to complete.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}
