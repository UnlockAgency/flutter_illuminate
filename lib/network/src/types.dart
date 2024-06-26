import 'package:illuminate/common.dart';
import 'package:illuminate/network/src/pkce.dart';

enum Authentication { none, oauth2, bearerToken }

enum HttpMethod {
  options,
  get,
  post,
  put,
  patch,
  delete;

  static HttpMethod? fromString(String value) {
    return values.firstOrNull((type) => type.name.toLowerCase() == value.toLowerCase());
  }
}

class Request {
  final HttpMethod httpMethod;
  final String path;
  final dynamic body;
  Map<String, dynamic>? extra;
  Map<String, dynamic>? query;
  Map<String, dynamic>? headers;
  final Authentication authentication;

  Request({
    required this.path,
    this.httpMethod = HttpMethod.get,
    this.body,
    this.extra,
    this.query,
    this.headers,
    this.authentication = Authentication.none,
  });
}

class OAuthConfig {
  final String host;
  final String tokenEndpoint;
  final String clientId;
  final String? authorizeEndpoint;
  final String? clientSecret;
  final bool pkceEnabled;
  final bool noTokenRefresh;

  OAuthConfig({
    required this.host,
    required this.tokenEndpoint,
    required this.clientId,
    this.authorizeEndpoint,
    this.clientSecret,
    this.pkceEnabled = false,
    this.noTokenRefresh = false,
  });
}

class ApiConfig {
  final String host;
  final OAuthConfig? oAuthConfig;

  const ApiConfig({
    required this.host,
    this.oAuthConfig,
  });
}

class AuthorizationRequest {
  final String url;
  final String redirectUri;
  final PKCEPair? pkcePair;

  const AuthorizationRequest({
    required this.url,
    required this.redirectUri,
    this.pkcePair,
  });
}
