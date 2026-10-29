import 'package:analytics_tracker/core/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

const savedLogin = {'auth.refresh_token': 'refresh-1'};

void main() {
  testWidgets('a saved login opens straight on the dashboard', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Tracker Test App'), findsOneWidget);
    expect(server.calls('POST', '/auth/login'), isEmpty);
  });

  testWidgets('switching project from the header loads that project\'s numbers', (tester) async {
    usePhoneSize(tester);
    final server = happyServer(projects: [projectJson(), projectJson(id: 'proj-2', name: 'Car Website', platform: 'web')]);
    server.on('GET', '/orgs/org-1/projects/proj-2/insights/overview', (_) => FakeResponse.ok(overviewJson(empty: true)));
    await pumpApp(tester, server, secureStorage: savedLogin);

    await tester.tap(find.byKey(const Key('overview-project-name')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Car Website'));
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(find.byKey(const Key('overview-project-name'))).data, 'Car Website');
    expect(server.calls('GET', '/orgs/org-1/projects/proj-2/insights/overview'), hasLength(1));
    expect(find.text('No events yet'), findsOneWidget);
  });

  testWidgets('an organization without projects shows how to add one', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer(projects: []), secureStorage: savedLogin);
    expect(find.text('No projects yet'), findsWidgets);
  });

  testWidgets('a user in no organization (e.g. platform owner) sees an explanation', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer(me: meJson(superadmin: true, organizations: [])), secureStorage: savedLogin);
    expect(find.text('No organization yet'), findsOneWidget);
  });

  testWidgets('bottom tabs switch screens', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer(), secureStorage: savedLogin);

    final bar = find.byType(NavigationBar);
    await tester.tap(find.descendant(of: bar, matching: find.text('Events')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('events-list')), findsOneWidget);

    await tester.tap(find.descendant(of: bar, matching: find.text('Users')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('users-list')), findsOneWidget);

    await tester.tap(find.descendant(of: bar, matching: find.text('Alerts')));
    await tester.pumpAndSettle();
    expect(find.text('Rules that notify you when an event happens or crosses a threshold.'), findsOneWidget);

    await tester.tap(find.descendant(of: bar, matching: find.text('More')));
    await tester.pumpAndSettle();
    expect(find.text('admin@example.com'), findsOneWidget);
    expect(find.text('Admin of One'), findsOneWidget);

    await tester.tap(find.descendant(of: bar, matching: find.text('Overview')));
    await tester.pumpAndSettle();
    expect(find.text('Tracker Test App'), findsOneWidget);
  });

  testWidgets('dark theme from More is applied and remembered', (tester) async {
    usePhoneSize(tester);
    final container = await pumpApp(tester, happyServer(), secureStorage: savedLogin);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('More')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NavigationBar));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      container.read(sharedPreferencesProvider).getString('settings.theme_mode'),
      'dark',
    );
  });

  testWidgets('switching to Hindi translates the app', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer(), secureStorage: savedLogin);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('More')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();

    final bar = find.byType(NavigationBar);
    expect(find.descendant(of: bar, matching: find.text('सारांश')), findsOneWidget);
    expect(find.descendant(of: bar, matching: find.text('और')), findsOneWidget);
    expect(find.text('भाषा'), findsOneWidget);
  });

  testWidgets('sign out asks first, revokes the login and returns to Sign in', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('More')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('sign-out')));
    await tester.tap(find.byKey(const Key('sign-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(server.calls('POST', '/auth/logout'), isEmpty);

    await tester.tap(find.byKey(const Key('sign-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-sign-out')));
    await tester.pumpAndSettle();

    expect(server.calls('POST', '/auth/logout'), hasLength(1));
    expect(find.byKey(const Key('signin-submit')), findsOneWidget);
  });
}
