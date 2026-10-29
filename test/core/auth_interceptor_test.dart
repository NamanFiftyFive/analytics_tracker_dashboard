import 'package:analytics_tracker/core/network/api_exception.dart';
import 'package:analytics_tracker/core/providers.dart';
import 'package:analytics_tracker/features/auth/application/auth_controller.dart';
import 'package:analytics_tracker/features/workspace/data/workspace_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('adds the access token to API calls', () async {
    final server = happyServer();
    final container = await makeContainer(server);
    container.read(tokenStorageProvider).accessToken = 'access-1';

    await container.read(workspaceRepositoryProvider).projects('org-1');
    expect(server.requests.single.headers['Authorization'], 'Bearer access-1');
  });

  test('on 401 it refreshes the tokens once and repeats the request', () async {
    final server = happyServer();
    server.sequence('GET', '/orgs/org-1/projects', [
      FakeResponse.error(401, 'Access token is invalid or expired'),
      FakeResponse.ok([projectJson()]),
    ]);
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});
    final tokens = container.read(tokenStorageProvider)..accessToken = 'expired';

    final projects = await container.read(workspaceRepositoryProvider).projects('org-1');

    expect(projects.single.name, 'Tracker Test App');
    expect(server.calls('POST', '/auth/refresh'), hasLength(1));
    expect(server.calls('POST', '/auth/refresh').single.data, {'refresh_token': 'refresh-1'});
    expect(server.calls('GET', '/orgs/org-1/projects').last.headers['Authorization'], 'Bearer access-2');
    expect(tokens.accessToken, 'access-2');
    expect(await tokens.readRefreshToken(), 'refresh-2', reason: 'rotated refresh token is saved');
  });

  test('several 401s at the same time share ONE refresh (each refresh token works once)', () async {
    final server = happyServer();
    var calls = 0;
    server.on('GET', '/orgs/org-1/projects', (request) {
      calls++;
      return request.headers['Authorization'] == 'Bearer access-2'
          ? FakeResponse.ok([projectJson()])
          : FakeResponse.error(401, 'expired');
    });
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});
    container.read(tokenStorageProvider).accessToken = 'expired';
    final repo = container.read(workspaceRepositoryProvider);

    await Future.wait([repo.projects('org-1'), repo.projects('org-1'), repo.projects('org-1')]);

    expect(server.calls('POST', '/auth/refresh'), hasLength(1));
    expect(calls, 6, reason: '3 first attempts + 3 retries');
  });

  test('when the refresh token no longer works, the user is signed out', () async {
    final server = happyServer();
    server.on('GET', '/orgs/org-1/projects', (_) => FakeResponse.error(401, 'expired'));
    server.on('POST', '/auth/refresh', (_) => FakeResponse.error(401, 'Refresh token is invalid or expired'));
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});
    final tokens = container.read(tokenStorageProvider)..accessToken = 'expired';

    await expectLater(
      container.read(workspaceRepositoryProvider).projects('org-1'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
    expect(tokens.accessToken, isNull);
    expect(await tokens.readRefreshToken(), isNull);
    expect(await container.read(authControllerProvider.future), isNull);
  });

  test('a wrong password (401 on login) does not try to refresh', () async {
    final server = happyServer();
    server.on('POST', '/auth/login', (_) => FakeResponse.error(401, 'Incorrect email or password'));
    final container = await makeContainer(server);

    await expectLater(
      container.read(authControllerProvider.notifier).signIn(email: 'a@b.co', password: 'wrongpass'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Incorrect email or password')),
    );
    expect(server.calls('POST', '/auth/refresh'), isEmpty);
  });

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('offline while refreshing: the original error is reported and the login is kept', () async {
    final server = happyServer();
    server.on('GET', '/orgs/org-1/projects', (_) => FakeResponse.error(401, 'expired'));
    server.offline('POST', '/auth/refresh');
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});
    final tokens = container.read(tokenStorageProvider)..accessToken = 'expired';

    await expectLater(
      container.read(workspaceRepositoryProvider).projects('org-1'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
    expect(await tokens.readRefreshToken(), 'refresh-1', reason: 'no network is not a reason to sign out');
  });

  test('a repeated request that fails again is reported, and is not refreshed twice', () async {
    final server = happyServer();
    server.sequence('GET', '/orgs/org-1/projects', [
      FakeResponse.error(401, 'expired'),
      FakeResponse.error(401, 'still not allowed'),
    ]);
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});
    container.read(tokenStorageProvider).accessToken = 'expired';

    await expectLater(
      container.read(workspaceRepositoryProvider).projects('org-1'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'still not allowed')),
    );
    expect(server.calls('POST', '/auth/refresh'), hasLength(1), reason: 'no refresh loop');
  });
}
