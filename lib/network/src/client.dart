import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:illuminate/network/src/interceptors/authentication_interceptor.dart';
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
      ),
    );

    final oAuthConfig = config.oAuthConfig;
    if (oAuthConfig != null) {
      oAuthAuthenticator = OAuthAuthenticator(host: oAuthConfig.host, config: oAuthConfig);

      _dioClient.interceptors.add(
        AuthenticationInterceptor(
          client: this,
          authenticator: oAuthAuthenticator!,
        ),
      );
    }
  }

  Future<Response> request(Request request) async {
    try {
      Response response = await _dioClient.request(
        request.path,
        data: request.body,
        queryParameters: request.query,
        options: Options(
          method: request.httpMethod.name,
          headers: request.headers,
          responseType: ResponseType.plain,
          extra: {
            'authentication': request.authentication.name,
          },
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

      return response;
    } catch (exception, stacktrace) {
      logger.e('Cought: $exception\n\n$stacktrace');

      if (exceptionHandler != null) {
        await exceptionHandler!(exception, stacktrace);
      }

      rethrow;
    }
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
}
