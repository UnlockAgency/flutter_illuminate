class OAuthConfigurationException implements Exception {
  final String? message;

  OAuthConfigurationException({this.message});

  @override
  String toString() {
    return '[OAuthConfigurationException] message: $message';
  }
}

class OAuthSignInFailureException implements Exception {
  final String? message;

  OAuthSignInFailureException({this.message});

  @override
  String toString() {
    return '[OAuthSignInFailureException] message: $message';
  }
}

class OAuthSignInCanceledException implements Exception {
  OAuthSignInCanceledException();

  @override
  String toString() {
    return '[OAuthSignInCanceledException]';
  }
}

class ResponseException implements Exception {
  final int statusCode;
  final dynamic data;

  ResponseException({
    required this.statusCode,
    required this.data,
  });

  @override
  String toString() {
    return '[ResponseException] { statusCode: $statusCode, data: $data }';
  }
}
