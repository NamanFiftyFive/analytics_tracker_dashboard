import 'package:analytics_tracker/core/router/routes.dart';
import 'package:analytics_tracker/features/auth/application/auth_controller.dart';
import 'package:analytics_tracker/features/workspace/application/workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

const savedLogin = {'auth.refresh_token': 'refresh-1'};

Future<void> openMembers(WidgetTester tester) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('More')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('more-members')));
  await tester.pumpAndSettle();
}

Finder roleChipOf(String userId) =>
    find.descendant(of: find.byKey(Key('member-$userId')), matching: find.byKey(const Key('role-chip')));

Future<void> fillAddMember(WidgetTester tester, {required String email, String password = ''}) async {
  await tester.tap(find.byKey(const Key('add-member')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('member-email')), email);
  if (password.isNotEmpty) await tester.enterText(find.byKey(const Key('member-password')), password);
}

Future<void> submitAddMember(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('submit-member')));
  await tester.tap(find.byKey(const Key('submit-member')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('More → Members lists the team with roles and a You tag', (tester) async {
    usePhoneSize(tester);
    await pumpApp(tester, happyServer(), secureStorage: savedLogin);
    await openMembers(tester);

    expect(find.text('Test Admin'), findsOneWidget);
    expect(find.text('Riya Shah'), findsOneWidget);
    expect(find.text('viewer@example.com'), findsOneWidget, reason: 'no name: the email is the title');
    expect(find.text('You'), findsOneWidget);
    expect(find.text('riya@example.com · Joined Oct 1, 2026'), findsOneWidget);
    expect(find.byKey(const Key('add-member')), findsOneWidget, reason: 'admin can add');
    expect(roleChipOf('user-2'), findsOneWidget, reason: 'admin can change roles');
  });

  testWidgets('a viewer sees the team but cannot add, change roles or remove others', (tester) async {
    usePhoneSize(tester);
    final server = happyServer(me: meJson(organizations: [membershipJson(role: 'viewer')]));
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    expect(find.text('Riya Shah'), findsOneWidget);
    expect(find.byKey(const Key('add-member')), findsNothing);
    expect(find.byKey(const Key('role-chip')), findsNothing);
    expect(find.byKey(const Key('member-menu-user-2')), findsNothing);
    expect(find.byKey(const Key('member-menu-user-1')), findsOneWidget, reason: 'anyone can leave');
  });

  testWidgets('add member: sends email, role and password, shows a confirmation', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    await fillAddMember(tester, email: 'new@example.com', password: 'Welcome123');
    await tester.enterText(find.byKey(const Key('member-name')), 'New Person');
    await tester.tap(find.descendant(of: find.byKey(const Key('member-role')), matching: find.text('Analyst')));
    await tester.pumpAndSettle();
    await submitAddMember(tester);

    final body = server.calls('POST', '/orgs/org-1/members').single.data as Map;
    expect(body, {'email': 'new@example.com', 'role': 'analyst', 'full_name': 'New Person', 'password': 'Welcome123'});
    expect(find.text('new@example.com added as Analyst'), findsOneWidget);
    expect(server.calls('GET', '/orgs/org-1/members'), hasLength(2), reason: 'list reloads');
  });

  testWidgets('add member: an existing account needs no password; role defaults to viewer', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    await fillAddMember(tester, email: 'old@example.com');
    await submitAddMember(tester);

    expect(server.calls('POST', '/orgs/org-1/members').single.data, {'email': 'old@example.com', 'role': 'viewer'});
  });

  testWidgets('add member: server errors stay in the form', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    server.sequence('POST', '/orgs/org-1/members', [
      FakeResponse.error(400, 'No account exists for this email; a password is required to create one'),
      FakeResponse.error(409, 'This user is already a member of the organization'),
    ]);
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    await fillAddMember(tester, email: 'nobody@example.com');
    await submitAddMember(tester);
    expect(find.text('No account exists for this email; a password is required to create one'), findsOneWidget);

    await submitAddMember(tester);
    expect(find.text('This user is already a member of the organization'), findsOneWidget);
    expect(find.byKey(const Key('submit-member')), findsOneWidget, reason: 'sheet stays open');
  });

  testWidgets('add member: a too-short password is caught before sending', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    await fillAddMember(tester, email: 'new@example.com', password: 'short');
    await submitAddMember(tester);
    expect(server.calls('POST', '/orgs/org-1/members'), isEmpty);
  });

  testWidgets('change role: PATCHes the new role and confirms', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    await tester.tap(roleChipOf('user-2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('role-option-viewer')));
    await tester.pumpAndSettle();

    expect(server.calls('PATCH', '/orgs/org-1/members/user-2').single.data, {'role': 'viewer'});
    expect(find.text('Role changed to Viewer'), findsOneWidget);
  });

  testWidgets('demoting the last admin shows the server reason', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    server.on('PATCH', '/orgs/org-1/members/user-1',
        (_) => FakeResponse.error(409, 'An organization must keep at least one admin'));
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    await tester.tap(roleChipOf('user-1'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('role-option-analyst')));
    await tester.pumpAndSettle();

    expect(find.text('An organization must keep at least one admin'), findsOneWidget);
    expect(server.calls('GET', '/auth/me'), hasLength(1), reason: 'no session refresh on failure');
  });

  testWidgets('remove a member after confirming', (tester) async {
    usePhoneSize(tester);
    final server = happyServer();
    await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    await tester.tap(find.byKey(const Key('member-menu-user-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();
    expect(find.text('Remove riya@example.com?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(server.calls('DELETE', '/orgs/org-1/members/user-2'), isEmpty, reason: 'cancel does nothing');

    await tester.tap(find.byKey(const Key('member-menu-user-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-remove-member')));
    await tester.pumpAndSettle();
    expect(server.calls('DELETE', '/orgs/org-1/members/user-2'), hasLength(1));
  });

  testWidgets('leaving refreshes the session and goes back to Overview', (tester) async {
    usePhoneSize(tester);
    final server = happyServer(me: meJson(organizations: [membershipJson(), membershipJson(id: 'org-2', name: 'Two')]));
    server.sequence('GET', '/auth/me', [
      FakeResponse.ok(meJson(organizations: [membershipJson(), membershipJson(id: 'org-2', name: 'Two')])),
      FakeResponse.ok(meJson(organizations: [membershipJson(id: 'org-2', name: 'Two')])),
    ]);
    server.on('DELETE', '/orgs/org-1/members/user-1', (_) => FakeResponse.ok(null));
    server.on('GET', '/orgs/org-2/projects', (_) => FakeResponse.ok([]));
    final container = await pumpApp(tester, server, secureStorage: savedLogin);
    await openMembers(tester);

    await tester.tap(find.byKey(const Key('member-menu-user-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave organization').last);
    await tester.pumpAndSettle();
    expect(find.text('Leave One?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-remove-member')));
    await tester.pumpAndSettle();

    expect(server.calls('DELETE', '/orgs/org-1/members/user-1'), hasLength(1));
    expect(container.read(authControllerProvider).value!.memberships.map((o) => o.organizationId), ['org-2']);
    expect(container.read(workspaceControllerProvider).value!.organization.organizationId, 'org-2');
    final router = GoRouter.of(tester.element(find.byType(NavigationBar)));
    expect(router.routerDelegate.currentConfiguration.uri.path, Routes.overview);
  });
}
