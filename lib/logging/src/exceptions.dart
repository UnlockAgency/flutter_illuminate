class InvalidServiceAccountException implements Exception {
  final String? message;

  InvalidServiceAccountException({this.message});

  @override
  String toString() {
    return '[InvalidServiceAccountException] message: $message';
  }
}
