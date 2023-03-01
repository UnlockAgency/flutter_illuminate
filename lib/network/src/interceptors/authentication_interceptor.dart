import 'package:dio/dio.dart';
import 'package:illuminate/network.dart';
import 'package:illuminate/network/src/utils.dart';
import 'dart:math';

class AuthenticationInterceptor extends QueuedInterceptor {
  // final OAuthConfig config;
  // late Dio _dioClient;
  final Client client;
  final OAuthAuthenticator authenticator;

  AuthenticationInterceptor({
    required this.client,
    required this.authenticator,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String requestId = _requestId();
    options.extra['id'] = requestId;

    _requestLog(options);

    if (options.extra['authentication'] != Authentication.oauth2.name) {
      handler.next(options);
      return;
    }

    storageManager.read(storageKeyAccessToken).then((token) {
      options.headers['Authorization'] = 'Bearer $token';
      logger.d('REQUEST[$requestId] => Authorization: Bearer $token');
      handler.next(options);
    }).catchError((e) {
      handler.next(options);
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _responseLog(response);
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    String? requestId = err.requestOptions.extra['id'];

    _errorLog(err);

    // Check if the access token has expired
    if (!(err.response?.statusCode == 401)) {
      handler.next(err);
      return;
    }

    authenticator.refreshToken().then((token) async {
      logger.i('RESPONSE[$requestId] => Received new access token');

      var headers = err.requestOptions.headers;
      headers['Authorization'] = 'Bearer $token';

      _requestLog(err.requestOptions, attempt: 2);

      // Retry the original request
      Request requestObject = Request(
        path: err.requestOptions.path,
        httpMethod: HttpMethod.fromString(err.requestOptions.method) ?? HttpMethod.get,
        body: err.requestOptions.data,
        query: err.requestOptions.queryParameters,
        headers: headers,
      );

      return client.request(requestObject);
    }).then((response) {
      _responseLog(response);

      handler.resolve(response);
    }).catchError((error) {
      logger.e('ERROR[$requestId] => Error getting refresh token from storage: $error');
      handler.next(err);
    });
  }

  String _requestId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _requestLog(RequestOptions options, {int attempt = 1}) {
    String? requestId = options.extra['id'];
    final optionsCopy = options;
    optionsCopy.headers.remove('Authorization');

    logger.i('REQUEST[${requestId ?? '<no id>'}] #$attempt => Path: ${options.path}, query: ${options.queryParameters}');
    logger.i('REQUEST[${requestId ?? '<no id>'}] #$attempt => Headers: ${optionsCopy.headers}');
    logger.i('REQUEST[${requestId ?? '<no id>'}] #$attempt => Body: ${options.data}');
  }

  void _errorLog(DioError error) {
    String? requestId = error.requestOptions.extra['id'];
    logger.e('ERROR[${requestId ?? '<no id>'}] => Path: ${error.requestOptions.path}');
  }

  void _responseLog(Response response) {
    String? requestId = response.requestOptions.extra['id'];
    logger.i('RESPONSE[${requestId ?? '<no id>'}] => Path: ${response.requestOptions.path}, content: ${response.data}');
  }
}
