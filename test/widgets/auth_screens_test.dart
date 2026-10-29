import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

Future<void> enter(WidgetTester tester, String key, String text) =>
    tester.enterText(find.byKey(Key(key)), text);

void main() {
  testWidgets('no saved login: the app opens on Sign in', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer());
    expect(find.text('See what people do in your app, screen by screen.'), findsOneWidget);
    expect(find.byKey(const Key('signin-submit')), findsOneWidget);
  });

  testWidgets('sign in: empty and invalid fields are caught before any request', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server);

    await tester.tap(find.byKey(const Key('signin-submit')));
    await tester.pump();
    expect(find.text('This field is required'), findsNWidgets(2));

    await enter(tester, 'signin-email', 'not-an-email');
    await tester.tap(find.byKey(const Key('signin-submit')));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(server.calls('POST', '/auth/login'), isEmpty);
  });

  testWidgets('sign in: the server\'s error is shown and the user stays on the screen', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    server.on('POST', '/auth/login', (_) => FakeResponse.error(401, 'Incorrect email or password'));
    await pumpApp(tester, server);

    await enter(tester, 'signin-email', 'admin@example.com');
    await enter(tester, 'signin-password', 'wrongpass');
    await tester.tap(find.byKey(const Key('signin-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password'), findsOneWidget);
    expect(find.byKey(const Key('signin-submit')), findsOneWidget);
  });

  testWidgets('sign in: offline shows a connection message', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    server.offline('POST', '/auth/login');
    await pumpApp(tester, server);

    await enter(tester, 'signin-email', 'admin@example.com');
    await enter(tester, 'signin-password', 'supersecret1');
    await tester.tap(find.byKey(const Key('signin-submit')));
    await tester.pumpAndSettle();

    expect(find.text("Can't reach the server. Check your connection and try again."), findsOneWidget);
  });

  testWidgets('sign in: success opens the dashboard with the project', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer());

    await enter(tester, 'signin-email', 'admin@example.com');
    await enter(tester, 'signin-password', 'supersecret1');
    await tester.tap(find.byKey(const Key('signin-submit')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Tracker Test App'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
  });

  testWidgets('register: validates, sends the form and lands on the dashboard', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server);

    await tester.tap(find.byKey(const Key('go-register')));
    await tester.pumpAndSettle();
    expect(find.text('Create your organization'), findsOneWidget);

    await enter(tester, 'register-organization', 'A');
    await enter(tester, 'register-password', 'short');
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();
    expect(find.text('Use at least 2 characters'), findsOneWidget);
    expect(find.text('Use at least 8 characters'), findsOneWidget);
    expect(server.calls('POST', '/auth/register'), isEmpty);

    await enter(tester, 'register-organization', 'Acme Motors');
    await enter(tester, 'register-name', 'Asha');
    await enter(tester, 'register-email', 'asha@acme.com');
    await enter(tester, 'register-password', 'supersecret1');
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(server.calls('POST', '/auth/register').single.data, {
      'organization_name': 'Acme Motors',
      'full_name': 'Asha',
      'email': 'asha@acme.com',
      'password': 'supersecret1',
    });
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('register: an email that is taken shows the server message', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    server.on('POST', '/auth/register', (_) => FakeResponse.error(409, 'An account with this email already exists'));
    await pumpApp(tester, server);
    await tester.tap(find.byKey(const Key('go-register')));
    await tester.pumpAndSettle();

    await enter(tester, 'register-organization', 'Acme Motors');
    await enter(tester, 'register-name', 'Asha');
    await enter(tester, 'register-email', 'asha@acme.com');
    await enter(tester, 'register-password', 'supersecret1');
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('An account with this email already exists'), findsOneWidget);
  });
}
