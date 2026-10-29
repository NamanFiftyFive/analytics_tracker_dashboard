import 'package:analytics_tracker/core/network/api_client.dart';
import 'package:analytics_tracker/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';

void main() {
  late FakeServer server;
  late ApiClient api;

  setUp(() {
    server = FakeServer();
    api = ApiClient(Dio(BaseOptions(baseUrl: 'http://test/api/v1'))..httpClientAdapter = server);
  });

  test('returns the envelope\'s data', () async {
    server.on('GET', '/thing', (_) => FakeResponse.ok({'name': 'Car App'}));
    final name = await api.get('/thing', (data) => (data as Map)['name']);
    expect(name, 'Car App');
  });

  test('a server error becomes ApiException with the server\'s message', () async {
    server.on('POST', '/auth/register', (_) => FakeResponse.error(409, 'An account with this email already exists'));
    await expectLater(
      api.post('/auth/register', (_) {}, body: {}),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.server)
          .having((e) => e.statusCode, 'status', 409)
          .having((e) => e.message, 'message', 'An account with this email already exists')),
    );
  });

  test('no connection becomes a network error', () async {
    server.offline('GET', '/thing');
    await expectLater(
      api.get('/thing', (data) => data),
      throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.network)),
    );
  });

  test('a response without "data" is reported as unexpected', () async {
    server.on('GET', '/thing', (_) => const FakeResponse(200, {'hello': 'world'}));
    await expectLater(
      api.get('/thing', (data) => data),
      throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.unknown)),
    );
  });

  test('requests sent with authenticated: false are marked to skip auth', () async {
    server.on('POST', '/auth/login', (_) => FakeResponse.ok(null));
    await api.post('/auth/login', (_) {}, body: {}, authenticated: false);
    expect(server.requests.single.extra[skipAuth], isTrue);
  });
}
