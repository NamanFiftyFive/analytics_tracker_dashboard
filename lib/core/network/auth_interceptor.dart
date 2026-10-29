import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_client.dart';
import 'token_refresher.dart';

/// Adds `Authorization: Bearer <access token>` to requests. When the server answers 401
/// (access token expired after 15 minutes), it refreshes the tokens once and repeats the
/// request; if refreshing fails, the session is over and [onSessionExpired] is called.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokens,
    required this.refresher,
    required this.onSessionExpired,
  });

  /// The Dio this interceptor belongs to, used to repeat the request.
  final Dio dio;
  final TokenStorage tokens;
  final TokenRefresher refresher;
  final void Function() onSessionExpired;

  static const _retried = 'authRetried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.accessToken;
    if (token != null && options.extra[skipAuth] != true) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final canRefresh = err.response?.statusCode == 401 &&
        options.extra[skipAuth] != true &&
        options.extra[_retried] != true;
    if (!canRefresh) return handler.next(err);

    final bool refreshed;
    try {
      refreshed = await refresher.refresh();
    } on DioException {
      return handler.next(err); // offline while refreshing: report the original error
    }
    if (!refreshed) {
      onSessionExpired();
      return handler.next(err);
    }

    options.extra[_retried] = true;
    options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    try {
      handler.resolve(await dio.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
