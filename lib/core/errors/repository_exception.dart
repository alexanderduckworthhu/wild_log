/// Thrown when a local persistence operation fails.
class RepositoryException implements Exception {
  RepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      cause == null ? 'RepositoryException: $message' : 'RepositoryException: $message ($cause)';
}
