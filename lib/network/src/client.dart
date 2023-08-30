import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:illuminate/network/src/exceptions/exceptions.dart';
import 'package:illuminate/network/src/interceptors/authentication_interceptor.dart';
import 'package:illuminate/network/src/interceptors/logger_interceptor.dart';
import 'package:illuminate/network/src/oauth_authenticator.dart';
import 'package:illuminate/network/src/transformer/json_transformer.dart';
import 'package:illuminate/network/src/utils.dart';
import 'package:illuminate/network/src/types.dart';
import 'package:illuminate/utils.dart';

/// Must be top-level function
Map<String, dynamic> _parseAndDecode(String response) {
  return jsonDecode(response) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class Client {
  final ApiConfig config;
  late Future<void> Function(Object exception, StackTrace stackTrace)? exceptionHandler;
  late Dio _dioClient;

  OAuthAuthenticator? _oAuthAuthenticator;
  AuthenticationDelegate? _authenticationDelegate;
  OAuthAuthenticationDelegate? _oAuthAuthenticationDelegate;

  Client(this.config, {this.exceptionHandler}) {
    _dioClient = Dio(
      BaseOptions(
        baseUrl: config.host,
        responseType: ResponseType.json,
        // This prevents exceptions without response body when the status code isn't 2XX
        validateStatus: (_) => true,
      ),
    )..transformer = JSONTransformer();

    _dioClient.interceptors.add(LoggerInterceptor());

    final oAuthConfig = config.oAuthConfig;
    if (oAuthConfig != null) {
      _oAuthAuthenticator = OAuthAuthenticator(host: oAuthConfig.host, config: oAuthConfig);
    }

    _dioClient.interceptors.add(
      AuthenticationInterceptor(
        config: config,
        authenticator: _oAuthAuthenticator,
        onAuthenticationFailure: _onAuthenticationFailure,
        onTokenRefreshFailure: _onTokenRefreshFailure,
      ),
    );
  }

  Future<Response<dynamic>> request(Request request) async {
    try {
      String requestId = _requestId();

      Response<dynamic> response = await _dioClient.request<dynamic>(
        request.path,
        data: request.body,
        queryParameters: request.query,
        options: Options(
          method: request.httpMethod.name,
          headers: request.headers,
          responseType: ResponseType.json,
          extra: (request.extra ?? {})
            ..addAll({
              'id': requestId,
              'authentication': request.authentication.name,
            }),
        ),
      );

      try {
        // Sometimes, we're still getting a parsed response from DIO.
        // For instance, when we're refreshing a token in the interceptor.
        // So, to be sure, check before decoding JSON if i's value is in fact a string.
        response.data = response.data is String ? jsonDecode(response.data) : response.data;
      } on FormatException catch (_) {
        logger.w('[REQ] Response couldn\'t be decoded to json, using plain text as fallback');
      }

      int statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw ResponseException(statusCode: statusCode, data: response.data);
      }

      return response;
    } on ResponseException catch (exception, stacktrace) {
      logger.e('Response error', error: exception, stackTrace: stacktrace);

      if (exceptionHandler != null) {
        await exceptionHandler!(exception, stacktrace);
      }

      rethrow;
    } catch (exception, stacktrace) {
      logger.e('Cought request error', error: exception, stackTrace: stacktrace);

      if (exceptionHandler != null) {
        await exceptionHandler!(exception, stacktrace);
      }

      rethrow;
    }
  }

  Future<void> setAccessToken(String token) async {
    await storageManager.write(storageKeyAccessToken, token);
  }

  Future<String?> getAccessToken() async {
    return await storageManager.read(storageKeyAccessToken);
  }

  Future<String> refreshToken() async {
    if (_oAuthAuthenticator == null) {
      throw ArgumentError.value(config.oAuthConfig, 'OAuthConfig', "There's not OAuthConfig present");
    }

    return await _oAuthAuthenticator!.refreshToken();
  }

  setAuthenticationDelegate(AuthenticationDelegate delegate) => _authenticationDelegate = delegate;
  Future<void> _onAuthenticationFailure() async {
    await _authenticationDelegate?.onAuthenticationFailure();
  }

  setOAuthAuthenticationDelegate(OAuthAuthenticationDelegate delegate) => _oAuthAuthenticationDelegate = delegate;
  Future<void> _onTokenRefreshFailure() async {
    await _oAuthAuthenticationDelegate?.onTokenRefreshFailure();
  }

  Future<void> clear() async {
    await storageManager.delete(storageKeyAccessToken);
    await storageManager.delete(storageKeyRefreshToken);
  }

  String _requestId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}

abstract class AuthenticationDelegate {
  Future<void> onAuthenticationFailure();
}

abstract class OAuthAuthenticationDelegate {
  Future<void> onTokenRefreshFailure();
}
