import 'package:dio/dio.dart';
import 'package:illuminate/network.dart';
import 'package:illuminate/network/src/interceptors/logger_interceptor.dart';
import 'package:illuminate/network/src/utils.dart';
import 'package:illuminate/utils.dart';

class AuthenticationInterceptor extends QueuedInterceptor {
  late Dio _dioClient;

  final OAuthAuthenticator? authenticator;
  final Future<void> Function()? onAuthenticationFailure;

  AuthenticationInterceptor({
    required ApiConfig config,
    this.authenticator,
    this.onAuthenticationFailure,
  }) {
    _dioClient = Dio(
      BaseOptions(
        baseUrl: config.host,
        responseType: ResponseType.plain,
      ),
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String? requestId = options.extra['id'];

    if (options.extra['authentication'] != Authentication.oauth2.name && options.extra['authentication'] != Authentication.bearerToken.name) {
      handler.next(options);
      return;
    }

    storageManager.read(storageKeyAccessToken).then((token) {
      options.headers['Authorization'] = 'Bearer $token';
      logger.d('REQUEST[$requestId] => Authorization: Bearer $token');
      handler.next(options);
    }).catchError((e) {
      logger.e('Unable to read access token', e);
      handler.next(options);
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String? requestId = response.requestOptions.extra['id'];
    String? authentication = response.requestOptions.extra['authentication'];

    // Check the response code
    int statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      handler.next(response);
      return;
    }

    if (statusCode != 401) {
      // Let the client convert it to a ResponseException
      handler.next(response);
      return;
    }

    if (authentication != Authentication.oauth2.name) {
      // OAuth flow isn't used, it's a plain bearer token
      if (onAuthenticationFailure != null) {
        onAuthenticationFailure!();
      }

      handler.next(response);
      return;
    }

    // Try to refresh the token
    _refreshToken(requestOptions: response.requestOptions, requestId: requestId).then((response) {
      LoggerInterceptor.responseLog(response);

      handler.next(response);
    }).catchError((error) {
      logger.e('ERROR[$requestId] => Error getting refresh token from storage: $error');

      // Resolve the original response
      handler.next(response);
    });
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    String? requestId = err.requestOptions.extra['id'];
    String? authentication = err.requestOptions.extra['authentication'];

    // Check if the access token has expired
    if (!(err.response?.statusCode == 401)) {
      handler.next(err);
      return;
    }

    if (authentication != Authentication.oauth2.name) {
      // OAuth flow isn't used, it's a plain bearer token
      if (onAuthenticationFailure != null) {
        onAuthenticationFailure!();
      }

      handler.next(err);
      return;
    }

    _refreshToken(requestOptions: err.requestOptions, requestId: requestId).then((response) {
      LoggerInterceptor.responseLog(response);

      handler.resolve(response);
    }).catchError((error) {
      logger.e('ERROR[$requestId] => Error getting refresh token from storage: $error');
      handler.next(err);
    });
  }

  Future<Response<dynamic>> _refreshToken({required RequestOptions requestOptions, String? requestId}) {
    if (authenticator == null) {
      return Future.error(OAuthConfigurationException(message: 'OAuth not configured'));
    }

    return authenticator!.refreshToken().then((token) {
      logger.i('RESPONSE[$requestId] => Received new access token');

      return _retryRequest(requestOptions, token);
    });
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions, String accessToken) async {
    LoggerInterceptor.requestLog(requestOptions, attempt: 2);

    var headers = requestOptions.headers;
    headers['Authorization'] = 'Bearer $accessToken';

    return await _dioClient.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        responseType: ResponseType.plain,
      ),
    );
  }
}
