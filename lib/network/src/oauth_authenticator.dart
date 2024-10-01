import 'package:illuminate/common.dart';
import 'package:dio/dio.dart';
import 'package:illuminate/network/src/client.dart';
import 'package:illuminate/network/src/exceptions/exceptions.dart';
import 'package:illuminate/network/src/pkce.dart';
import 'package:illuminate/network/src/types.dart';
import 'package:illuminate/network/src/utils.dart';

class OAuthAuthenticator {
  final OAuthConfig config;
  final Client _tokenClient;

  OAuthAuthenticator({required String host, required this.config})
      : _tokenClient = Client(
          ApiConfig(host: host),
        );

  String get authorizeUrl {
    String host = config.host;
    String? authorizeEndpoint = config.authorizeEndpoint;

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    if (authorizeEndpoint != null && authorizeEndpoint.startsWith("/")) {
      authorizeEndpoint = authorizeEndpoint.substring(1);
    }

    return '$host/$authorizeEndpoint';
  }

  AuthorizationRequest buildAuthorizionRequest(String redirectUri, String scope) {
    PKCEPair? pkcePair;
    String clientId = config.clientId;
    String? clientSecret = config.clientSecret;

    if (!config.pkceEnabled && clientSecret == null) {
      throw ArgumentError.value(config.clientSecret, 'clientSecret', 'The client secret should be configured');
    }

    Map<String, String> query = {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scope,
    };

    if (config.pkceEnabled) {
      pkcePair = PKCEPair.generate();
      query['code_challenge'] = pkcePair.codeChallenge;
      query['code_challenge_method'] = 'S256';
    }

    String queryString = Uri(queryParameters: query).query;
    String url = '$authorizeUrl?$queryString';

    return AuthorizationRequest(
      url: url,
      redirectUri: redirectUri,
      pkcePair: pkcePair,
    );
  }

  Future<Response> authenticate(String code, {AuthorizationRequest? authorizationRequest}) async {
    Map<String, String?> body = {
      'client_id': config.clientId,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': authorizationRequest?.redirectUri,
    };

    if (!config.pkceEnabled && config.clientSecret != null) {
      body['client_secret'] = config.clientSecret;
    } else if (config.pkceEnabled && authorizationRequest?.pkcePair != null) {
      body['code_verifier'] = authorizationRequest?.pkcePair?.codeVerifier;
    }

    Request requestObject = Request(
      path: config.tokenEndpoint,
      httpMethod: HttpMethod.post,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    try {
      Response response = await _tokenClient.request(requestObject);

      _storeTokens(response);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> refreshToken() async {
    final refreshToken = await storageManager.read(storageKeyRefreshToken);
    // final accessToken = await storageManager.read(storageKeyAccessToken);

    if (config.noTokenRefresh) {
      return refreshToken ?? '';
    }

    Map<String, dynamic> body = {
      'grant_type': 'refresh_token',
      'client_id': config.clientId,
      'refresh_token': refreshToken,
    };

    if (config.clientSecret != null) {
      body['client_secret'] = config.clientSecret;
    }

    Request requestObject = Request(
      path: config.tokenEndpoint,
      httpMethod: HttpMethod.post,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    Response response = await _tokenClient.request(requestObject);

    return await _storeTokens(response);
  }

  Future<String> _storeTokens(Response response) async {
    Map<String, dynamic>? data = tryCast<Map<String, dynamic>>(response.data);

    if (data == null) {
      throw OAuthSignInFailureException(message: 'Authorization response is not valid');
    }

    String? accessToken = tryCast<String>(data['access_token']);
    String? refreshToken = tryCast<String>(data['refresh_token']);

    if (accessToken == null || refreshToken == null) {
      throw OAuthSignInFailureException(message: 'Response does not contain an access and/or refresh token');
    }

    await storageManager.write(storageKeyAccessToken, accessToken);
    await storageManager.write(storageKeyRefreshToken, refreshToken);

    return accessToken;
  }

  Future<void> signOut() async {
    await storageManager.delete(storageKeyAccessToken);
    await storageManager.delete(storageKeyRefreshToken);
  }
}
