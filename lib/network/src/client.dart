import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:illuminate/network/src/interceptors/authentication_interceptor.dart';
import 'package:illuminate/network/src/utils.dart';
import 'package:illuminate/network/src/types.dart';

class Client {
  final ApiConfig config;
  late Future<void> Function(Object exception, StackTrace stackTrace)? exceptionHandler;
  late Dio _dioClient;

  Client(this.config, {this.exceptionHandler}) {
    _dioClient = Dio(
      BaseOptions(
        baseUrl: config.host,
        responseType: ResponseType.plain,
      ),
    );

    if (config.oAuthConfig != null) {
      _dioClient.interceptors.add(AuthenticationInterceptor(config.oAuthConfig!));
    }
  }

  Future<Response> request(Request request) async {
    logger.d('[REQ] ${request.httpMethod.name.toUpperCase()} ${request.path}, query: ${request.query}, body: ${request.body}, headers: ${request.headers}');

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
        response.data = jsonDecode(response.data);
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
}
