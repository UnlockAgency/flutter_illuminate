import 'package:dio/dio.dart';
import 'package:illuminate/network/src/types.dart';
import 'package:illuminate/network/src/utils.dart';

class AuthenticationInterceptor extends QueuedInterceptor {
  final OAuthConfig config;
  late Dio _dioClient;

  AuthenticationInterceptor(this.config) {
    _dioClient = Dio(BaseOptions(
      baseUrl: config.host,
    ));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('REQUEST[${options.method}] => PATH: ${options.path}');

    if (options.extra['authentication'] != Authentication.oauth2) {
      handler.next(options);
      return;
    }

    storageManager.read(storageKeyAccessToken).then((token) {
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }).catchError((_) {
      handler.next(options);
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    logger.e('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');

    // Check if the access token has expired
    if (!(err.response?.statusCode == 401 && err.requestOptions.path != '/auth/logout' && err.requestOptions.path != '/auth/login')) {
      handler.next(err);
      return;
    }

    storageManager.read(storageKeyRefreshToken).then((token) {
      // Refresh the token
      return _dioClient.request(config.tokenEndpoint, data: {
        'grant_type': 'refresh_token',
        'client_id': config.clientId,
        'client_secret': config.clientSecret,
        'refresh_token': token,
      });
    }).then((response) {
      // Retry the original request
      return _dioClient.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
        ),
      );
    }).then((response) {
      handler.resolve(response);
    }).catchError((error) {
      logger.e('Error getting refresh token from storage: $error');
      handler.next(err);
    });
  }
}
