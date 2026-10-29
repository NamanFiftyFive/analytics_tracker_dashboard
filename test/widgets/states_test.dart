import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

/// What each screen shows when the server fails, when lists are long, and the less common
/// paths: switching organization, super admins, users with no organization or no project.
const savedLogin = {'auth.refresh_token': 'refresh-1'};

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}

Future<void> openMore(WidgetTester tester, String key) async {
  await openTab(tester, 'More');
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Finder scrollableOf(String listKey) =>
    find.descendant(of: find.byKey(Key(listKey)), matching: find.byType(Scrollable));

void main() {
  group('workspace failing to load', () {
    testWidgets('Overview offers to try again', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.sequence('GET', '/orgs/org-1/projects', [FakeResponse.error(500, 'Internal server error'), FakeResponse.ok([projectJson()])]);
      await pumpApp(tester, server, secureStorage: savedLogin);

      expect(find.text("Couldn't load your workspace"), findsOneWidget);
      expect(find.text('Internal server error'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('kpi-events')), findsOneWidget);
    });

    testWidgets('Events and Users explain why there is nothing to show', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.sequence('GET', '/orgs/org-1/projects', [FakeResponse.error(503, 'Database unavailable'), FakeResponse.ok([projectJson()])]);
      await pumpApp(tester, server, secureStorage: savedLogin);

      await openTab(tester, 'Events');
      expect(find.text('Database unavailable'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('events-list')), findsOneWidget);
    });

    testWidgets('no network shows a connection message', (tester) async {
      usePhoneSize(tester);
      final server = happyServer()..offline('GET', '/orgs/org-1/projects');
      await pumpApp(tester, server, secureStorage: savedLogin);
      expect(find.text("Can't reach the server. Check your connection and try again."), findsOneWidget);
    });

    testWidgets('an organization without projects: Events and Users say so', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(projects: []), secureStorage: savedLogin);
      await openTab(tester, 'Events');
      expect(find.text('No projects yet'), findsOneWidget);
      await openTab(tester, 'Users');
      expect(find.text('No projects yet'), findsOneWidget);
    });

    testWidgets('a user in no organization: Events and Members say so', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(me: meJson(organizations: [])), secureStorage: savedLogin);
      await openTab(tester, 'Events');
      expect(find.text('No organization yet'), findsOneWidget);
    });
  });

  group('Events', () {
    testWidgets('the feed failing offers to try again', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.sequence('GET', '$projectPath/events', [FakeResponse.error(500, 'Internal server error'), FakeResponse.ok(eventPageJson())]);
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Events');

      expect(find.text('Internal server error'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('events-list')), findsOneWidget);
    });

    testWidgets('loading older events failing keeps the list and says so', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      final page = [for (var i = 0; i < 20; i++) eventJson(id: 'p$i', name: 'car_viewed', minutesAgo: i + 1)];
      server.sequence('GET', '$projectPath/events', [
        FakeResponse.ok(eventPageJson(items: page, nextCursor: 'page-2')),
        FakeResponse.error(500, 'Internal server error'),
      ]);
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Events');

      await tester.scrollUntilVisible(find.text("Couldn't load more. Pull down to refresh."), 500,
          scrollable: scrollableOf('events-list'));
      expect(find.text('car_viewed'), findsWidgets);

      // Scrolling more doesn't keep hitting the failing server; the message stays.
      await tester.drag(scrollableOf('events-list'), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(server.calls('GET', '$projectPath/events'), hasLength(2));
      expect(find.text("Couldn't load more. Pull down to refresh."), findsOneWidget);
    });
  });

  group('Users', () {
    testWidgets('scrolling to the end loads the next 50 users', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      final first = [for (var i = 0; i < 50; i++) personJson(id: 'p$i', distinctId: 'user_$i', lastSeenMinutesAgo: i + 1)];
      server.on('GET', '$projectPath/persons', (request) => request.queryParameters['offset'] == 50
          ? FakeResponse.ok(personPageJson(items: [personJson(id: 'p50', distinctId: 'user_from_page_2')], total: 51))
          : FakeResponse.ok(personPageJson(items: first, total: 51)));
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Users');

      await tester.scrollUntilVisible(find.text('user_from_page_2'), 500, scrollable: scrollableOf('users-list'));
      expect(server.calls('GET', '$projectPath/persons').last.queryParameters['offset'], 50);
    });

    testWidgets('loading more users failing says so', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      final first = [for (var i = 0; i < 50; i++) personJson(id: 'p$i', distinctId: 'user_$i')];
      server.sequence('GET', '$projectPath/persons', [
        FakeResponse.ok(personPageJson(items: first, total: 80)),
        FakeResponse.error(500, 'Internal server error'),
      ]);
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Users');

      await tester.scrollUntilVisible(find.text("Couldn't load more. Pull down to refresh."), 500,
          scrollable: scrollableOf('users-list'));
      await tester.drag(scrollableOf('users-list'), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(server.calls('GET', '$projectPath/persons'), hasLength(2));
    });

    testWidgets('search waits for typing to stop and shows when nothing matches', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.on('GET', '$projectPath/persons', (request) => (request.queryParameters['search'] ?? '') == ''
          ? FakeResponse.ok(personPageJson())
          : FakeResponse.ok(personPageJson(items: [])));
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Users');

      await tester.enterText(find.byKey(const Key('users-search')), 'nobody');
      await tester.pump(const Duration(milliseconds: 200));
      expect(server.calls('GET', '$projectPath/persons'), hasLength(1), reason: 'still typing');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(server.calls('GET', '$projectPath/persons').last.queryParameters['search'], 'nobody');
      expect(find.text('No matching users'), findsOneWidget);
    });

    testWidgets('the list failing offers to try again', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.sequence('GET', '$projectPath/persons', [FakeResponse.error(500, 'Internal server error'), FakeResponse.ok(personPageJson())]);
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Users');

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('customer_1042'), findsOneWidget);
    });

    testWidgets('a user that no longer exists', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.sequence('GET', '$projectPath/persons/person-1', [FakeResponse.error(404, 'User not found'), FakeResponse.ok(personDetailJson())]);
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Users');
      await tester.tap(find.text('customer_1042'));
      await tester.pumpAndSettle();

      expect(find.text('This user no longer exists.'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('person-distinct-id')), findsOneWidget);
    });
  });

  group('Members and projects', () {
    testWidgets('members failing to load offers to try again', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.sequence('GET', '/orgs/org-1/members', [FakeResponse.error(500, 'Internal server error'), FakeResponse.ok(membersJson())]);
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openMore(tester, 'more-members');

      expect(find.text("Couldn't load members"), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Riya Shah'), findsOneWidget);
    });

    testWidgets('API keys failing to load offers to try again', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.sequence('GET', '$projectPath/api-keys', [FakeResponse.error(500, 'Internal server error'), FakeResponse.ok(apiKeysJson())]);
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openMore(tester, 'more-projects');
      await tester.tap(find.text('Tracker Test App'));
      await tester.pumpAndSettle();

      expect(find.text('Internal server error'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Default key'), findsOneWidget);
    });

    Future<FakeServer> openKeys(WidgetTester tester, void Function(FakeServer server) setUp) async {
      usePhoneSize(tester);
      final server = happyServer();
      setUp(server);
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openMore(tester, 'more-projects');
      await tester.tap(find.text('Tracker Test App'));
      await tester.pumpAndSettle();
      return server;
    }

    testWidgets('creating a key that fails shows the reason', (tester) async {
      await openKeys(tester, (server) =>
          server.on('POST', '$projectPath/api-keys', (_) => FakeResponse.error(403, 'This organization is suspended')));
      await tester.tap(find.byKey(const Key('new-key')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('key-name')), 'iOS release');
      await tester.tap(find.byKey(const Key('create-key')));
      await tester.pumpAndSettle();
      expect(find.text('This organization is suspended'), findsOneWidget);
    });

    testWidgets('revoking a key that fails shows the reason', (tester) async {
      await openKeys(tester, (server) =>
          server.on('DELETE', '$projectPath/api-keys/key-1', (_) => FakeResponse.error(404, 'API key not found')));
      await tester.tap(find.byKey(const Key('revoke-key-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-revoke')));
      await tester.pumpAndSettle();
      expect(find.text('API key not found'), findsOneWidget);
    });
  });

  group('More', () {
    testWidgets('switching organization loads that organization\'s projects', (tester) async {
      usePhoneSize(tester);
      final server = happyServer(
        me: meJson(organizations: [membershipJson(), membershipJson(id: 'org-2', name: 'Two', role: 'viewer')]),
      );
      server.on('GET', '/orgs/org-2/projects', (_) => FakeResponse.ok([projectJson(id: 'proj-2', name: 'Second App')]));
      server.on('GET', '/orgs/org-2/projects/proj-2/insights/overview', (_) => FakeResponse.ok(overviewJson()));
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'More');

      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();
      expect(find.text('Choose an organization'), findsOneWidget);
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(server.calls('GET', '/orgs/org-2/projects'), hasLength(1));
      expect(find.text('Two'), findsWidgets);
      await openTab(tester, 'Overview');
      expect(server.calls('GET', '/orgs/org-2/projects/proj-2/insights/overview'), isNotEmpty);
    });

    testWidgets('with one organization there is nothing to switch', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(), secureStorage: savedLogin);
      await openTab(tester, 'More');
      expect(find.text('Switch'), findsNothing);
    });

    testWidgets('a super admin is marked', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(me: meJson(superadmin: true, organizations: [])), secureStorage: savedLogin);
      await openTab(tester, 'More');
      expect(find.text('Super admin'), findsWidgets);
    });
  });
}
