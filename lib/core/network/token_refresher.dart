import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Swaps the stored refresh token for a new token pair (`POST /auth/refresh`).
/// Several requests failing with 401 at once share ONE refresh call, because the backend
/// accepts each refresh token only once.
class TokenRefresher {
  TokenRefresher(this._dio, this._tokens);

  /// A Dio WITHOUT the auth interceptor, so refreshing can't trigger another refresh.
  final Dio _dio;
  final TokenStorage _tokens;
  Completer<bool>? _inFlight;

  /// True when new tokens were saved; false when the session is over (tokens cleared).
  Future<bool> refresh() {
    final running = _inFlight;
    if (running != null) return running.future;

    final completer = Completer<bool>();
    _inFlight = completer;
    completer.complete(_refresh()); // errors (offline) reach every waiting caller too
    return completer.future.whenComplete(() => _inFlight = null);
  }

  Future<bool> _refresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await _dio.post<Object?>('/auth/refresh', data: {'refresh_token': refreshToken});
      final data = (response.data as Map)['data'] as Map;
      await _tokens.save(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return true;
    } on DioException catch (error) {
      // No answer at all (offline): keep the tokens so the user stays signed in.
      if (error.response == null) rethrow;
      await _tokens.clear(); // refresh token expired, revoked or reused
      return false;
    }
  }
}
