import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

const savedLogin = {'auth.refresh_token': 'refresh-1'};

Finder inTabBar(String label) => find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(inTabBar(label));
  await tester.pumpAndSettle();
}

/// The event-name chips scroll sideways; bring one into view like a user would.
Future<Finder> chip(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(ChoiceChip, label);
  await tester.scrollUntilVisible(finder, 100,
      scrollable: find.descendant(of: find.byKey(const Key('event-chips')), matching: find.byType(Scrollable)));
  await tester.ensureVisible(finder); // fully on screen, not just peeking in at the edge
  await tester.pumpAndSettle();
  return finder;
}

Finder inCard(String key, String text) => find.descendant(of: find.byKey(Key(key)), matching: find.text(text));

void main() {
  group('Overview', () {
    testWidgets('shows KPIs with their change, the chart and top lists', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      await pumpApp(tester, server, secureStorage: savedLogin);

      expect(inCard('kpi-active-users', '248'), findsOneWidget);
      expect(inCard('kpi-active-users', '↑ 12.2%'), findsOneWidget);
      expect(inCard('kpi-events', '7,570'), findsOneWidget);
      expect(inCard('kpi-sessions', '612'), findsOneWidget);
      expect(inCard('kpi-sessions', '↓ 3%'), findsOneWidget);
      expect(inCard('kpi-avg-session', '4m 12s'), findsOneWidget);
      expect(find.byKey(const Key('bar-6')), findsOneWidget, reason: '7 bars for 7 days');

      await tester.scrollUntilVisible(find.text('test_drive_booked'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('CarList'), findsOneWidget);
      expect(find.text('2,140 views'), findsOneWidget);
      expect(find.text('test_drive_booked'), findsOneWidget);
      expect(server.calls('GET', '$projectPath/insights/overview').single.queryParameters['range'], '7d');
    });

    testWidgets('choosing another range asks for that range', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      await pumpApp(tester, server, secureStorage: savedLogin);

      await tester.tap(find.descendant(of: find.byKey(const Key('overview-range')), matching: find.text('30 days')));
      await tester.pumpAndSettle();

      final ranges = server.calls('GET', '$projectPath/insights/overview').map((r) => r.queryParameters['range']);
      expect(ranges, ['7d', '30d']);
    });

    testWidgets('a project without events explains what to do', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.on('GET', '$projectPath/insights/overview', (_) => FakeResponse.ok(overviewJson(empty: true)));
      await pumpApp(tester, server, secureStorage: savedLogin);

      expect(find.text('No events yet'), findsOneWidget);
      expect(inCard('kpi-events', '0'), findsOneWidget);
      expect(find.text('Nothing in this period yet.'), findsWidgets);
    });

    testWidgets('an error offers to try again', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.sequence('GET', '$projectPath/insights/overview', [
        FakeResponse.error(500, 'Internal server error'),
        FakeResponse.ok(overviewJson()),
      ]);
      await pumpApp(tester, server, secureStorage: savedLogin);

      expect(find.text('Internal server error'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(inCard('kpi-active-users', '248'), findsOneWidget);
    });
  });

  group('Events', () {
    testWidgets('lists events under a day header with the event-name chips', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(), secureStorage: savedLogin);
      await openTab(tester, 'Events');

      expect(find.text('TODAY'), findsOneWidget);
      final list = find.byKey(const Key('events-list'));
      expect(find.descendant(of: list, matching: find.text('test_drive_booked')), findsOneWidget);
      expect(find.descendant(of: list, matching: find.text('car_liked')), findsOneWidget);
      expect(find.text('model: Nexon EV · showroom: Baner'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'All events'), findsOneWidget);
      expect(await chip(tester, 'car_liked'), findsOneWidget);
    });

    testWidgets('a chip filters by event name', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Events');

      await tester.tap(await chip(tester, 'car_liked'));
      await tester.pumpAndSettle();

      expect(server.calls('GET', '$projectPath/events').last.queryParameters['event'], 'car_liked');
    });

    testWidgets('search waits until typing stops, then sends one request', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Events');
      final before = server.calls('GET', '$projectPath/events').length;

      await tester.enterText(find.byKey(const Key('events-search')), 'Nex');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byKey(const Key('events-search')), 'Nexon');
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      final calls = server.calls('GET', '$projectPath/events');
      expect(calls.length, before + 1);
      expect(calls.last.queryParameters['search'], 'Nexon');
    });

    testWidgets('scrolling to the end loads older events with the cursor', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      final firstPage = [for (var i = 0; i < 20; i++) eventJson(id: 'p1-$i', name: 'car_viewed', minutesAgo: i + 1)];
      server.on('GET', '$projectPath/events', (request) => request.queryParameters['cursor'] == 'page-2'
          ? FakeResponse.ok(eventPageJson(items: [eventJson(id: 'old', name: 'old_event_from_page_2', minutesAgo: 120)]))
          : FakeResponse.ok(eventPageJson(items: firstPage, nextCursor: 'page-2')));
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Events');

      await tester.scrollUntilVisible(find.text('old_event_from_page_2'), 500,
          scrollable: find.descendant(of: find.byKey(const Key('events-list')), matching: find.byType(Scrollable)));

      expect(server.calls('GET', '$projectPath/events').last.queryParameters['cursor'], 'page-2');
      expect(find.text('old_event_from_page_2'), findsOneWidget);
    });

    testWidgets('tapping an event opens that user, and back returns to Events', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(), secureStorage: savedLogin);
      await openTab(tester, 'Events');

      await tester.tap(find.descendant(of: find.byKey(const Key('events-list')), matching: find.text('test_drive_booked')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const Key('person-distinct-id'))).data, 'customer_1042');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('events-list')), findsOneWidget);
    });

    testWidgets('no events yet', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.on('GET', '$projectPath/events', (_) => FakeResponse.ok(eventPageJson(items: [])));
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Events');
      expect(find.text('No events yet'), findsOneWidget);
    });
  });

  group('Users', () {
    testWidgets('lists users with counts on the filter', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(), secureStorage: savedLogin);
      await openTab(tester, 'Users');

      expect(find.text('All 3'), findsOneWidget);
      expect(find.text('Known 1'), findsOneWidget);
      expect(find.text('New 2'), findsOneWidget);
      expect(find.text('customer_1042'), findsOneWidget);
      expect(find.text('Pune · premium · Android 14'), findsOneWidget);
      expect(find.text('186 events'), findsOneWidget);
      expect(find.text('Anonymous · Android 14'), findsOneWidget);
    });

    testWidgets('the Known filter asks for identified users', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Users');

      await tester.tap(find.text('Known 1'));
      await tester.pumpAndSettle();

      expect(server.calls('GET', '$projectPath/persons').last.queryParameters['filter'], 'identified');
    });

    testWidgets('a user\'s timeline shows traits, totals and session steps', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(), secureStorage: savedLogin);
      await openTab(tester, 'Users');

      await tester.tap(find.text('customer_1042'));
      await tester.pumpAndSettle();

      expect(find.text('city: Pune'), findsOneWidget);
      expect(find.text('14'), findsOneWidget, reason: 'sessions');
      expect(find.text('186'), findsOneWidget, reason: 'events');
      expect(find.text('5m 0s'), findsOneWidget, reason: 'session length');
      expect(find.text('test_drive_booked'), findsOneWidget);
      expect(find.text(r'$app_open'), findsOneWidget);
      expect(find.text('BookTestDrive · model: Nexon EV'), findsOneWidget);
    });

    testWidgets('no users yet', (tester) async {
      usePhoneSize(tester);
      final server = happyServer();
      server.on('GET', '$projectPath/persons', (_) => FakeResponse.ok(personPageJson(items: [])));
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Users');
      expect(find.text('No users yet'), findsOneWidget);
    });
  });

  group('Project-wise data', () {
    const proj2Path = '/orgs/org-1/projects/proj-2';

    FakeServer twoProjects() {
      final server = happyServer(projects: [projectJson(), projectJson(id: 'proj-2', name: 'Car Website', platform: 'web')]);
      server.on('GET', '$proj2Path/insights/overview', (_) => FakeResponse.ok(overviewJson(empty: true)));
      server.on('GET', '$proj2Path/events', (_) => FakeResponse.ok(eventPageJson(items: [
            eventJson(id: 'w1', name: 'page_viewed_on_website', personId: null, screen: null),
          ])));
      server.on('GET', '$proj2Path/event-definitions', (_) => FakeResponse.ok(<Object>[]));
      server.on('GET', '$proj2Path/persons', (_) => FakeResponse.ok(personPageJson(items: [
            personJson(id: 'web-person', distinctId: 'website_visitor_1', properties: const {}),
          ])));
      return server;
    }

    Future<void> switchProjectHere(WidgetTester tester, String projectId) async {
      await tester.tap(find.byKey(const Key('tab-project-switcher')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('pick-project-$projectId')));
      await tester.pumpAndSettle();
    }

    testWidgets('Events shows which project it is for', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, twoProjects(), secureStorage: savedLogin);
      await openTab(tester, 'Events');
      expect(tester.widget<Text>(find.byKey(const Key('tab-project-name'))).data, 'Tracker Test App');
    });

    testWidgets('switching project on Events loads only that project\'s events', (tester) async {
      usePhoneSize(tester);
      final server = twoProjects();
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Events');
      expect(find.text('test_drive_booked'), findsWidgets);

      await switchProjectHere(tester, 'proj-2');

      expect(tester.widget<Text>(find.byKey(const Key('tab-project-name'))).data, 'Car Website');
      expect(server.calls('GET', '$proj2Path/events'), hasLength(1));
      expect(find.text('page_viewed_on_website'), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('events-list')), matching: find.text('test_drive_booked')),
          findsNothing, reason: 'the other project\'s events are gone');
    });

    testWidgets('the choice is shared: Users and Overview follow', (tester) async {
      usePhoneSize(tester);
      final server = twoProjects();
      await pumpApp(tester, server, secureStorage: savedLogin);
      await openTab(tester, 'Events');
      await switchProjectHere(tester, 'proj-2');

      await openTab(tester, 'Users');
      expect(tester.widget<Text>(find.byKey(const Key('tab-project-name'))).data, 'Car Website');
      expect(find.text('website_visitor_1'), findsOneWidget);
      expect(find.text('customer_1042'), findsNothing);

      await openTab(tester, 'Overview');
      expect(tester.widget<Text>(find.byKey(const Key('overview-project-name'))).data, 'Car Website');
      expect(server.calls('GET', '$proj2Path/insights/overview'), hasLength(1));
    });

    testWidgets('with a single project there is nothing to switch', (tester) async {
      usePhoneSize(tester);
      await pumpApp(tester, happyServer(), secureStorage: savedLogin);
      await openTab(tester, 'Events');
      await tester.tap(find.byKey(const Key('tab-project-switcher')));
      await tester.pumpAndSettle();
      expect(find.text('Choose a project'), findsNothing);
    });
  });
}
