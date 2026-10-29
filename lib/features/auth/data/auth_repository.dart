import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/token_refresher.dart';
import '../../../core/providers.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_models.dart';

/// Sign in, sign up, restore the session on app start, sign out.
class AuthRepository {
  AuthRepository(this._api, this._tokens, this._refresher);

  final ApiClient _api;
  final TokenStorage _tokens;
  final TokenRefresher _refresher;

  Future<AuthSession> signIn({required String email, required String password}) async {
    final tokens = await _api.post(
      '/auth/login',
      _parseTokens,
      body: {'email': email, 'password': password},
      authenticated: false,
    );
    return _startSession(tokens);
  }

  /// Creates the organization; the new user becomes its admin.
  Future<AuthSession> register({
    required String organizationName,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final tokens = await _api.post(
      '/auth/register',
      _parseTokens,
      body: {
        'organization_name': organizationName,
        'full_name': fullName,
        'email': email,
        'password': password,
      },
      authenticated: false,
    );
    return _startSession(tokens);
  }

  /// On app start: uses the saved refresh token to sign back in. Null when there is none or
  /// it no longer works.
  Future<AuthSession?> restore() async {
    if (await _tokens.readRefreshToken() == null) return null;
    try {
      if (!await _refresher.refresh()) return null;
    } on DioException {
      return null; // offline: show sign-in rather than a broken dashboard
    }
    return me();
  }

  Future<AuthSession> me() => _api.get('/auth/me', (data) => AuthSession.fromJson(_map(data)));

  /// Revokes the refresh token on the server (best effort) and forgets the tokens here.
  Future<void> signOut() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _api.post('/auth/logout', (_) {}, body: {'refresh_token': refreshToken}, authenticated: false);
      } catch (_) {
        // Offline or already expired: signing out locally is still correct.
      }
    }
    await _tokens.clear();
  }

  Future<AuthSession> _startSession(AuthTokens tokens) async {
    await _tokens.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
    return me();
  }

  static AuthTokens _parseTokens(Object? data) => AuthTokens.fromJson(_map(data));

  static Map<String, dynamic> _map(Object? data) => Map<String, dynamic>.from(data as Map);
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
    ref.watch(tokenRefresherProvider),
  ),
);
