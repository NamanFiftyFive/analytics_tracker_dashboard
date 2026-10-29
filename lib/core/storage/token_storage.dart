import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the login tokens. The short-lived access token stays in memory only; the refresh
/// token is kept in the device's secure storage (Keychain / Keystore) to stay signed in.
class TokenStorage {
  TokenStorage(this._secure);

  final FlutterSecureStorage _secure;
  static const _refreshTokenKey = 'auth.refresh_token';

  String? accessToken;

  Future<String?> readRefreshToken() => _secure.read(key: _refreshTokenKey);

  Future<void> save({required String accessToken, required String refreshToken}) async {
    this.accessToken = accessToken;
    await _secure.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    accessToken = null;
    await _secure.delete(key: _refreshTokenKey);
  }
}
