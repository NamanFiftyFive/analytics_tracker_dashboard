import 'package:analytics_tracker/features/workspace/application/workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

const savedLogin = {'auth.refresh_token': 'refresh-1'};

Future<void> openProjects(WidgetTester tester) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('More')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('more-projects')));
  await tester.pumpAndSettle();
}

Future<void> openProjectDetail(WidgetTester tester) async {
  await openProjects(tester);
  await tester.tap(find.text('Tracker Test App'));
  await tester.pumpAndSettle();
}

/// A viewer's session: same organization, lower role.
FakeServer viewerServer() => happyServer(me: meJson(organizations: [membershipJson(role: 'viewer')]));

void main() {
  testWidgets('More shows the projects row; it opens the list', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer(), secureStorage: savedLogin);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('More')));
    await tester.pumpAndSettle();

    expect(find.text('Projects and API keys'), findsOneWidget);
    expect(find.text('1 project'), findsOneWidget);

    await tester.tap(find.byKey(const Key('more-projects')));
    await tester.pumpAndSettle();
    expect(find.text('Tracker Test App'), findsOneWidget);
    expect(find.text('Flutter · Asia/Kolkata'), findsOneWidget);
    expect(find.text('1 active key'), findsOneWidget);
    expect(find.byKey(const Key('new-project')), findsOneWidget, reason: 'admin can create');
  });

  testWidgets('a viewer sees projects but cannot create or see keys', (tester) async {
    usePhoneSize(tester);
    final server = viewerServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openProjects(tester);

    expect(find.byKey(const Key('new-project')), findsNothing);
    expect(find.text('Only admins can create projects and manage API keys.'), findsOneWidget);

    await tester.tap(find.text('Tracker Test App'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('keys-admin-only')), findsOneWidget);
    expect(server.calls('GET', '$projectPath/api-keys'), isEmpty, reason: 'no request the backend would refuse');
  });

  testWidgets('project detail lists keys and the SDK setup', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer(), secureStorage: savedLogin);
    await openProjectDetail(tester);

    expect(find.text('Default key'), findsOneWidget);
    expect(find.text('pk_live_key-… · used 2 min ago'), findsOneWidget);
    expect(find.text('Old Android key'), findsOneWidget);
    expect(find.text('Revoked'), findsOneWidget);
    expect(find.byKey(const Key('revoke-key-old')), findsNothing, reason: 'revoked keys have no Revoke button');

    await tester.scrollUntilVisible(find.text('Add the SDK to your app'), 200,
        scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first);
    expect(find.textContaining("host: 'http://test'"), findsOneWidget, reason: 'host comes from .env');
  });

  testWidgets('new key: name it, see the full key once, list reloads', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openProjectDetail(tester);

    await tester.tap(find.byKey(const Key('new-key')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create-key')));
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('key-name')), 'iOS release');
    await tester.tap(find.byKey(const Key('create-key')));
    await tester.pumpAndSettle();

    expect(server.calls('POST', '$projectPath/api-keys').single.data, {'name': 'iOS release'});
    expect(find.text(newFullKey), findsOneWidget);
    expect(find.text('Copy your API key now'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text(newFullKey), findsNothing, reason: 'never shown again');
    expect(server.calls('GET', '$projectPath/api-keys'), hasLength(2), reason: 'list reloaded');
  });

  testWidgets('copy puts the key on the clipboard', (tester) async {
    usePhoneSize(tester);
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') clipboard = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpApp(tester, happyServer(), secureStorage: savedLogin);
    await openProjectDetail(tester);

    await tester.tap(find.byKey(const Key('new-key')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('key-name')), 'Web');
    await tester.tap(find.byKey(const Key('create-key')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('copy-key')));
    await tester.pump();

    expect(clipboard, newFullKey);
    expect(find.text('Copied'), findsOneWidget);
  });

  testWidgets('revoke asks first, then revokes and reloads', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openProjectDetail(tester);

    await tester.tap(find.byKey(const Key('revoke-key-1')));
    await tester.pumpAndSettle();
    expect(find.text('Revoke this key?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(server.calls('DELETE', '$projectPath/api-keys/key-1'), isEmpty);

    await tester.tap(find.byKey(const Key('revoke-key-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-revoke')));
    await tester.pumpAndSettle();
    expect(server.calls('DELETE', '$projectPath/api-keys/key-1'), hasLength(1));
    expect(server.calls('GET', '$projectPath/api-keys'), hasLength(2));
  });

  testWidgets('new project: sends the form, shows its first key, appears in the list', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    var created = false;
    server.on('GET', '/orgs/org-1/projects', (_) => FakeResponse.ok([
          projectJson(),
          if (created) projectJson(id: 'proj-new', name: 'Car Website', platform: 'web'),
        ]));
    server.on('POST', '/orgs/org-1/projects', (request) {
      created = true;
      return FakeResponse.ok({
        'project': projectJson(id: 'proj-new', name: 'Car Website', platform: 'web'),
        'api_key': createdKeyJson(name: 'Default key', id: 'key-new'),
      }, 201);
    });
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openProjects(tester);

    await tester.tap(find.byKey(const Key('new-project')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('project-name')), 'Car Website');
    await tester.tap(find.byKey(const Key('platform-web')));
    await tester.tap(find.byKey(const Key('create-project')));
    await tester.pumpAndSettle();

    expect(server.calls('POST', '/orgs/org-1/projects').single.data,
        {'name': 'Car Website', 'platform': 'web', 'timezone': 'Asia/Kolkata'});
    expect(find.text(newFullKey), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Car Website'), findsOneWidget);
    expect(find.text('Website · Asia/Kolkata'), findsOneWidget);
  });

  testWidgets('new project: the server\'s error is shown in the form', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    server.on('POST', '/orgs/org-1/projects',
        (_) => FakeResponse.error(422, "timezone: Value error, unknown timezone 'Mars/Base'"));
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openProjects(tester);

    await tester.tap(find.byKey(const Key('new-project')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('project-name')), 'Space App');
    await tester.enterText(find.byKey(const Key('project-timezone')), 'Mars/Base');
    await tester.tap(find.byKey(const Key('create-project')));
    await tester.pumpAndSettle();

    expect(find.text("timezone: Value error, unknown timezone 'Mars/Base'"), findsOneWidget);
  });

  testWidgets('the selected project stays selected when the workspace reloads', (tester) async {
    usePhoneSize(tester);
    final server = happyServer(projects: [projectJson(), projectJson(id: 'proj-2', name: 'Car Website', platform: 'web')]);
    final container = await pumpApp(tester, server, secureStorage: savedLogin);

    container.read(workspaceControllerProvider.notifier).selectProject('proj-2');
    await tester.runAsync(() => container.read(workspaceControllerProvider.notifier).reload());
    await tester.pumpAndSettle();

    expect(container.read(workspaceControllerProvider).value?.selectedProject?.id, 'proj-2');
  });
}
