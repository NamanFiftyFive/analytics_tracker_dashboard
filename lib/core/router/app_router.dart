import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/dashboard/presentation/dashboard_shell.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/members/presentation/members_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/overview/presentation/overview_screen.dart';
import '../../features/projects/presentation/project_detail_screen.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/users/presentation/person_detail_screen.dart';
import '../../features/users/presentation/users_screen.dart';
import 'routes.dart';

/// Sends people to the right place for their sign-in state:
///   checking saved login → splash · signed out → sign in / register · signed in → dashboard.
class AuthRedirect {
  const AuthRedirect(this.ref);

  final Ref ref;

  String? call(String location) {
    final auth = ref.read(authControllerProvider);
    if (auth.isLoading && !auth.hasValue) return location == Routes.splash ? null : Routes.splash;

    final signedIn = auth.value != null;
    final onAuthScreen = Routes.authScreens.contains(location);
    if (!signedIn) return onAuthScreen ? null : Routes.signIn;
    if (onAuthScreen || location == Routes.splash) return Routes.overview;
    return null;
  }
}

Widget _personDetail(GoRouterState state) => PersonDetailScreen(personId: state.pathParameters['personId']!);

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run the redirect whenever the signed-in state changes.
  final authChanges = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => authChanges.value++);
  ref.onDispose(authChanges.dispose);
  final redirect = AuthRedirect(ref);

  return GoRouter(
    initialLocation: Routes.overview,
    refreshListenable: authChanges,
    redirect: (context, state) => redirect(state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => DashboardShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.overview, builder: (_, _) => const OverviewScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.events,
              builder: (_, _) => const EventsScreen(),
              routes: [GoRoute(path: 'user/:personId', builder: (_, state) => _personDetail(state))],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.users,
              builder: (_, _) => const UsersScreen(),
              routes: [GoRoute(path: ':personId', builder: (_, state) => _personDetail(state))],
            ),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.alerts, builder: (_, _) => const AlertsScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.more,
              builder: (_, _) => const MoreScreen(),
              routes: [
                GoRoute(path: 'members', builder: (_, _) => const MembersScreen()),
                GoRoute(
                  path: 'projects',
                  builder: (_, _) => const ProjectsScreen(),
                  routes: [
                    GoRoute(
                      path: ':projectId',
                      builder: (_, state) => ProjectDetailScreen(projectId: state.pathParameters['projectId']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
