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
