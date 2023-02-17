import 'package:dio/dio.dart';
import 'package:illuminate/common.dart';
import 'package:illuminate/network.dart';
import 'package:illuminate/network/src/types.dart';
import 'package:illuminate/network/src/utils.dart';
import 'dart:math';
import 'dart:developer' as developer;

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
    String requestId = _requestId();
    options.extra['id'] = requestId;
    logger.i('REQUEST[$requestId] => PATH: ${options.path}');

    if (options.extra['authentication'] != Authentication.oauth2.name) {
      handler.next(options);
      return;
    }

    storageManager.read(storageKeyAccessToken).then((token) {
      options.headers['Authorization'] = 'Bearer $token';
      print('REQUEST[$requestId] => Authorization: Bearer $token');
      handler.next(options);
    }).catchError((e) {
      handler.next(options);
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String? requestId = response.requestOptions.extra['id'];
    logger.i('RESPONSE[${requestId ?? response.statusCode}] => PATH: ${response.requestOptions.path}, content: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    String? requestId = err.requestOptions.extra['id'];
    logger.e('ERROR[${requestId ?? err.response?.statusCode}] => PATH: ${err.requestOptions.path}');

    // Check if the access token has expired
    print("Should refresh: ${err.response?.statusCode == 401 && err.requestOptions.path != '/auth/logout' && err.requestOptions.path != '/auth/login'}");
    if (!(err.response?.statusCode == 401 && err.requestOptions.path != '/auth/logout' && err.requestOptions.path != '/auth/login')) {
      handler.next(err);
      return;
    }

    storageManager.read(storageKeyRefreshToken).then((token) {
      Map<String, dynamic> body = {
        'grant_type': 'refresh_token',
        'client_id': config.clientId,
        'refresh_token': token,
      };

      if (config.clientSecret != null) {
        body['client_secret'] = config.clientSecret;
      }

      print("refresh request: $body");

      // Refresh the token
      return _dioClient.request(
        config.tokenEndpoint,
        data: body,
        options: Options(
          method: 'post',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
    }).then((response) async {
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

      // Retry the original request
      return _dioClient.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          responseType: err.requestOptions.responseType,
        ),
      );
    }).then((response) {
      handler.resolve(response);
    }).catchError((error) {
      logger.e('Error getting refresh token from storage: $error');
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
}
