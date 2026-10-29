import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../features/auth/application/auth_controller.dart';
import 'config/app_config.dart';
import 'network/api_client.dart';
import 'network/api_exception.dart';
import 'network/auth_interceptor.dart';
import 'network/token_refresher.dart';
import 'storage/token_storage.dart';

/// When Riverpod should retry a failed provider (it retries everything by default).
/// Only network failures are retried, a few times with growing waits; a server answer like
/// 403 or 404 won't change on retry, so it's shown right away with a "Try again" button.
Duration? retryPolicy(int retryCount, Object error) {
  final isNetwork = error is ApiException && error.kind == ApiErrorKind.network;
  if (!isNetwork || retryCount >= 3) return null;
  return Duration(seconds: 1 << retryCount); // 1 s, 2 s, 4 s
}

/// From `.env` (loaded in main). Tests override this.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnv(dotenv));

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage(const FlutterSecureStorage()));

BaseOptions _baseOptions(AppConfig config) => BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

/// Optional custom HTTP adapter (tests plug a fake server in here). Null = real network.
final httpAdapterProvider = Provider<HttpClientAdapter?>((ref) => null);

final tokenRefresherProvider = Provider<TokenRefresher>((ref) {
  final dio = Dio(_baseOptions(ref.watch(appConfigProvider)));
  final adapter = ref.watch(httpAdapterProvider);
  if (adapter != null) dio.httpClientAdapter = adapter;
  return TokenRefresher(dio, ref.watch(tokenStorageProvider));
});

/// The Dio used for all API calls, with the auth interceptor.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions(ref.watch(appConfigProvider)));
  final adapter = ref.watch(httpAdapterProvider);
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      tokens: ref.watch(tokenStorageProvider),
      refresher: ref.watch(tokenRefresherProvider),
      // Read lazily when it happens, so there is no provider cycle at build time.
      onSessionExpired: () => ref.read(authControllerProvider.notifier).sessionExpired(),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)));
