import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:illuminate/network/src/exceptions/exceptions.dart';
import 'package:illuminate/network/src/interceptors/authentication_interceptor.dart';
import 'package:illuminate/network/src/interceptors/logger_interceptor.dart';
import 'package:illuminate/network/src/oauth_authenticator.dart';
import 'package:illuminate/network/src/utils.dart';
import 'package:illuminate/network/src/types.dart';

class Client {
  final ApiConfig config;
  late Future<void> Function(Object exception, StackTrace stackTrace)? exceptionHandler;
  late Dio _dioClient;

  late OAuthAuthenticator? oAuthAuthenticator;

  Client(this.config, {this.exceptionHandler}) {
    _dioClient = Dio(
      BaseOptions(
        baseUrl: config.host,
        responseType: ResponseType.plain,
        // This prevents exceptions without response body when the status code isn't 2XX
        validateStatus: (_) => true,
      ),
    );

    _dioClient.interceptors.add(LoggerInterceptor());

    final oAuthConfig = config.oAuthConfig;
    OAuthAuthenticator? oAuthAuthenticator;
    if (oAuthConfig != null) {
      oAuthAuthenticator = OAuthAuthenticator(host: oAuthConfig.host, config: oAuthConfig);
    }

    _dioClient.interceptors.add(
      AuthenticationInterceptor(
        config: config,
        authenticator: oAuthAuthenticator,
        onAuthenticationFailure: onAuthenticationFailure,
      ),
    );
  }

  Future<Response> request(Request request) async {
    try {
      String requestId = _requestId();

      Response response = await _dioClient.request(
        request.path,
        data: request.body,
        queryParameters: request.query,
        options: Options(
          method: request.httpMethod.name,
          headers: request.headers,
          responseType: ResponseType.plain,
          extra: {
            'id': requestId,
            'authentication': request.authentication.name,
          },
        ),
      );

      int statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw ResponseException(statusCode: statusCode, data: response.data);
      }

      try {
        // Sometimes, we're still getting a parsed response from DIO.
        // For instance, when we're refreshing a token in the interceptor.
        // So, to be sure, check before decoding JSON if i's value is in fact a string.
        response.data = response.data is String ? jsonDecode(response.data) : response.data;
      } on FormatException catch (_) {
        logger.w('[REQ] Response couldn\'t be decoded to json, using plain text as fallback');
      }

      return response;
    } on ResponseException catch (exception, stacktrace) {
      logger.e('Response error', exception, stacktrace);

      if (exceptionHandler != null) {
        await exceptionHandler!(exception, stacktrace);
      }

      rethrow;
    } catch (exception, stacktrace) {
      logger.e('Cought request error', exception, stacktrace);

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
    if (oAuthAuthenticator == null) {
      throw ArgumentError.value(config.oAuthConfig, 'OAuthConfig', "There's not OAuthConfig present");
    }

    return await oAuthAuthenticator!.refreshToken();
  }

  Future<void> onAuthenticationFailure() async {
    //
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
