import 'package:dio/dio.dart';
import 'package:illuminate/network/src/utils.dart';

class LoggerInterceptor extends QueuedInterceptor {
  LoggerInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requestLog(options);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    int statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      errorLog(response.requestOptions);
    } else {
      responseLog(response);
    }

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    errorLog(err.requestOptions);
    handler.next(err);
  }

  static void requestLog(RequestOptions options, {int attempt = 1}) {
    String? requestId = options.extra['id'];

    // Creating a clone, instead of assigning it, because that causes headers to be removed from the original object
    Map<String, dynamic> headers = {}..addAll(options.headers);
    headers.remove('Authorization');

    logger.i('REQUEST[${requestId ?? '<no id>'}] #$attempt => Path: ${options.path}, query: ${options.queryParameters}');
    logger.i('REQUEST[${requestId ?? '<no id>'}] #$attempt => Headers: $headers');
    logger.i('REQUEST[${requestId ?? '<no id>'}] #$attempt => Body: ${options.data}');
  }

  static void errorLog(RequestOptions requestOptions) {
    String? requestId = requestOptions.extra['id'];
    logger.e('ERROR[${requestId ?? '<no id>'}] => Path: ${requestOptions.path}');
  }

  static void responseLog(Response response) {
    String? requestId = response.requestOptions.extra['id'];
    logger.i('RESPONSE[${requestId ?? '<no id>'}] => Path: ${response.requestOptions.path}, content: ${response.data}');
  }
}
