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
      BaseOptions(baseUrl: config.host),
    );

    if (config.oAuthConfig != null) {
      _dioClient.interceptors.add(AuthenticationInterceptor(config.oAuthConfig!));
    }
  }

  Future<Response> request(Request request) async {
    logger.d('[REQ] ${request.httpMethod.name.toUpperCase()} ${request.path}, query: ${request.query}, body: ${request.body}, headers: ${request.headers}');

    try {
      return await _dioClient.request(
        request.path,
        data: request.body,
        queryParameters: request.query,
        options: Options(
          method: request.httpMethod.name,
          headers: request.headers,
          extra: {
            'authentication': request.authentication.name,
          },
        ),
      );
    } catch (exception, stacktrace) {
      logger.e('Cought: $exception\n\n$stacktrace');

      if (exceptionHandler != null) {
        await exceptionHandler!(exception, stacktrace);
      }

      rethrow;
    }
  }
}
