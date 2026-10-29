import 'package:analytics_tracker/core/network/api_exception.dart';
import 'package:analytics_tracker/core/providers.dart';
import 'package:analytics_tracker/features/auth/application/auth_controller.dart';
import 'package:analytics_tracker/features/auth/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('app start without a saved login: signed out, no requests', () async {
    final server = happyServer();
    final container = await makeContainer(server);
    expect(await container.read(authControllerProvider.future), isNull);
    expect(server.requests, isEmpty);
  });

  test('app start with a saved refresh token: refreshes and loads the user', () async {
    final server = happyServer();
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});

    final session = await container.read(authControllerProvider.future);

    expect(session?.user.email, 'admin@example.com');
    expect(session?.memberships.single.role, MemberRole.admin);
    expect(server.requests.map((r) => r.path), ['/auth/refresh', '/auth/me']);
  });

  test('app start with an expired refresh token: signed out and token removed', () async {
    final server = happyServer();
    server.on('POST', '/auth/refresh', (_) => FakeResponse.error(401, 'Refresh token is invalid or expired'));
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'old'});

    expect(await container.read(authControllerProvider.future), isNull);
    expect(await container.read(tokenStorageProvider).readRefreshToken(), isNull);
  });

  test('app start offline: shows sign-in instead of hanging', () async {
    final server = happyServer();
    server.offline('POST', '/auth/refresh');
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});
    expect(await container.read(authControllerProvider.future), isNull);
  });

  test('sign in saves the tokens and loads the session', () async {
    final server = happyServer();
    final container = await makeContainer(server);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).signIn(email: 'admin@example.com', password: 'supersecret1');

    expect(container.read(authControllerProvider).value?.user.email, 'admin@example.com');
    expect(server.calls('POST', '/auth/login').single.data, {'email': 'admin@example.com', 'password': 'supersecret1'});
    final tokens = container.read(tokenStorageProvider);
    expect(tokens.accessToken, 'access-1');
    expect(await tokens.readRefreshToken(), 'refresh-1');
  });

  test('failed sign in throws the server message and stays signed out', () async {
    final server = happyServer();
    server.on('POST', '/auth/login', (_) => FakeResponse.error(403, 'This account is disabled'));
    final container = await makeContainer(server);
    await container.read(authControllerProvider.future);

    await expectLater(
      container.read(authControllerProvider.notifier).signIn(email: 'x@y.co', password: 'whatever1'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'This account is disabled')),
    );
    expect(container.read(authControllerProvider).value, isNull);
  });

  test('register sends the form and signs in as admin of the new organization', () async {
    final server = happyServer();
    final container = await makeContainer(server);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).register(
          organizationName: 'Acme Motors',
          fullName: 'Asha',
          email: 'asha@acme.com',
          password: 'supersecret1',
        );

    expect(server.calls('POST', '/auth/register').single.data, {
      'organization_name': 'Acme Motors',
      'full_name': 'Asha',
      'email': 'asha@acme.com',
      'password': 'supersecret1',
    });
    expect(container.read(authControllerProvider).value, isNotNull);
  });

  test('sign out revokes the refresh token on the server and forgets it', () async {
    final server = happyServer();
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});
    await container.read(authControllerProvider.future); // refresh-1 → refresh-2

    await container.read(authControllerProvider.notifier).signOut();

    expect(server.calls('POST', '/auth/logout').single.data, {'refresh_token': 'refresh-2'});
    expect(container.read(authControllerProvider).value, isNull);
    expect(await container.read(tokenStorageProvider).readRefreshToken(), isNull);
  });

  test('sign out still works offline', () async {
    final server = happyServer();
    server.offline('POST', '/auth/logout');
    final container = await makeContainer(server, secureStorage: {'auth.refresh_token': 'refresh-1'});
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).signOut();
    expect(container.read(authControllerProvider).value, isNull);
  });
}
