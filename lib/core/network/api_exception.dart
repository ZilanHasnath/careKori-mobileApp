class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

String errorMessage(Object error) =>
    error is ApiException ? error.message : 'Something went wrong. Please try again.';
