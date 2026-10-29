/// Every screen's path, in one place.
abstract final class Routes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const register = '/register';

  // Bottom tabs
  static const overview = '/overview';
  static const events = '/events';
  static const users = '/users';
  static const alerts = '/alerts';
  static const more = '/more';

  /// A user's timeline, opened from the Events tab (back returns to Events).
  static String eventUser(String personId) => '$events/user/$personId';

  /// A user's timeline, opened from the Users tab.
  static String userDetail(String personId) => '$users/$personId';

  /// Under the More tab.
  static const projects = '$more/projects';
  static String projectDetail(String projectId) => '$projects/$projectId';
  static const members = '$more/members';

  static const authScreens = {signIn, register};
}
