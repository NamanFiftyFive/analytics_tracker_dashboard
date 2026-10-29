enum ApiErrorKind {
  /// No connection, DNS failure, timeout: the server was never reached.
  network,

  /// The server answered with an error ({"status": ..., "error": ...}).
  server,

  /// Anything else (unexpected response shape, bug).
  unknown,
}

/// The one error type the app's data layer throws.
class ApiException implements Exception {
  const ApiException(this.kind, {this.statusCode, this.message});

  const ApiException.network() : this(ApiErrorKind.network);

  final ApiErrorKind kind;
  final int? statusCode;

  /// The server's `error` text, safe to show to the user.
  final String? message;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException(${kind.name}, $statusCode, $message)';
}
