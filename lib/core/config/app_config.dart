import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Settings read from the `.env` file bundled with the app.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 20),
  });

  /// Backend URL including `/api/v1`, e.g. `http://localhost:8000/api/v1`.
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  /// Builds the config from a loaded `.env`. On Android `API_BASE_URL_ANDROID` wins when set,
  /// because the emulator reaches the computer's localhost through 10.0.2.2.
  factory AppConfig.fromEnv(DotEnv env, {TargetPlatform? platform}) {
    final target = platform ?? defaultTargetPlatform;
    final androidUrl = env.maybeGet('API_BASE_URL_ANDROID');
    final baseUrl = (target == TargetPlatform.android && androidUrl != null && androidUrl.isNotEmpty)
        ? androidUrl
        : env.get('API_BASE_URL');
    return AppConfig(
      apiBaseUrl: baseUrl.replaceAll(RegExp(r'/+$'), ''),
      connectTimeout: Duration(seconds: int.tryParse(env.maybeGet('CONNECT_TIMEOUT_SECONDS') ?? '') ?? 10),
      receiveTimeout: Duration(seconds: int.tryParse(env.maybeGet('RECEIVE_TIMEOUT_SECONDS') ?? '') ?? 20),
    );
  }
}
