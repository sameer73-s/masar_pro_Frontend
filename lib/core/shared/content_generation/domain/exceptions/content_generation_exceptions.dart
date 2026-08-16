class PlagiarismRejectedException implements Exception {
  final String message;
  PlagiarismRejectedException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}
