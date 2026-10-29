import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Marks a request that must not get a token or trigger a token refresh
/// (login, register, refresh, logout).
const skipAuth = 'skipAuth';

/// Talks to the backend. Every response has the shape
///   success: {"status": 200, "data": ...}
///   error:   {"status": 404, "error": "..."}
/// so callers only ever see `data` or an [ApiException].
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(String path, T Function(Object? data) parse, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query), parse);

  Future<T> post<T>(String path, T Function(Object? data) parse, {Object? body, bool authenticated = true}) =>
      _send(() => _dio.post<Object?>(path, data: body, options: _options(authenticated)), parse);

  Future<T> patch<T>(String path, T Function(Object? data) parse, {Object? body}) =>
      _send(() => _dio.patch<Object?>(path, data: body), parse);

  Future<T> delete<T>(String path, T Function(Object? data) parse) =>
      _send(() => _dio.delete<Object?>(path), parse);

  static Options? _options(bool authenticated) => authenticated ? null : Options(extra: {skipAuth: true});

  Future<T> _send<T>(Future<Response<Object?>> Function() request, T Function(Object? data) parse) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is! Map || !body.containsKey('data')) {
        throw const ApiException(ApiErrorKind.unknown, message: 'Unexpected response from the server');
      }
      return parse(body['data']);
    } on DioException catch (error) {
      throw toApiException(error);
    }
  }

  static ApiException toApiException(DioException error) {
    final response = error.response;
    if (response == null) return const ApiException.network();
    final body = response.data;
    final message = body is Map && body['error'] is String ? body['error'] as String : null;
    return ApiException(ApiErrorKind.server, statusCode: response.statusCode, message: message);
  }
}
