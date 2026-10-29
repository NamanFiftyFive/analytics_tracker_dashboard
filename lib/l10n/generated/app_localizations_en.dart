// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Analytics Tracker';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get heroTitle => 'See what people do in your app, screen by screen.';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle =>
      'Use the email your organization registered with, or the one your admin added.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@company.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get signInButton => 'Sign in';

  @override
  String get noAccountPrompt => 'New here?';

  @override
  String get createOrganizationLink => 'Create an organization';

  @override
  String get joinTeamNote =>
      'Joining a team? Your admin creates your account and gives you a temporary password.';

  @override
  String get registerTitle => 'Create your organization';

  @override
  String get registerSubtitle =>
      'You become its admin. Analysts and viewers you add later see only this organization\'s data.';

  @override
  String get organizationNameLabel => 'Organization name';

  @override
  String get organizationNameHint => 'Acme Motors';

  @override
  String get fullNameLabel => 'Your name';

  @override
  String get fullNameHint => 'Full name';

  @override
  String get workEmailLabel => 'Work email';

  @override
  String get nextStepsTitle => 'Next steps';

  @override
  String get nextStepsBody =>
      '1. Add a project for your app and copy its API key\n2. Add the SDK to your app\n3. Invite your team';

  @override
  String get createOrganizationButton => 'Create organization';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get signInLink => 'Sign in';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String get validationPasswordLength => 'Use at least 8 characters';

  @override
  String validationMinLength(int min) {
    return 'Use at least $min characters';
  }

  @override
  String get errorNetwork =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabEvents => 'Events';

  @override
  String get tabUsers => 'Users';

  @override
  String get tabAlerts => 'Alerts';

  @override
  String get tabMore => 'More';

  @override
  String get rangeToday => 'Today';

  @override
  String get range7Days => '7 days';

  @override
  String get range30Days => '30 days';

  @override
  String get range90Days => '90 days';

  @override
  String get dateRangeLabel => 'Date range';

  @override
  String get kpiActiveUsers => 'Active users';

  @override
  String get kpiEvents => 'Events';

  @override
  String get kpiSessions => 'Sessions';

  @override
  String get kpiAvgSession => 'Avg. session';

  @override
  String get insightsPending =>
      'Numbers appear here once the insights API is ready.';

  @override
  String get projectDetailsTitle => 'Project';

  @override
  String get platformLabel => 'Platform';

  @override
  String get timezoneLabel => 'Timezone';

  @override
  String get activeKeysLabel => 'Active API keys';

  @override
  String get selectProjectTitle => 'Choose a project';

  @override
  String get switchProject => 'Switch project';

  @override
  String get noProjectsTitle => 'No projects yet';

  @override
  String get noProjectsBody =>
      'An admin of this organization can add a project for each app or website.';

  @override
  String get noOrganizationsTitle => 'No organization yet';

  @override
  String get noOrganizationsBody =>
      'You\'re not a member of any organization. Ask an admin to add you.';

  @override
  String get loadFailedTitle => 'Couldn\'t load your workspace';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get eventsComingSoon =>
      'A live feed of every event your apps send, with search and filters.';

  @override
  String get usersComingSoon =>
      'Everyone who used your app, with their sessions and timeline.';

  @override
  String get alertsComingSoon =>
      'Rules that notify you when an event happens or crosses a threshold.';

  @override
  String get moreTitle => 'More';

  @override
  String get superAdminBadge => 'Super admin';

  @override
  String roleInOrganization(String role, String organization) {
    return '$role of $organization';
  }

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleAnalyst => 'Analyst';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get organizationLabel => 'Organization';

  @override
  String get switchOrganization => 'Switch';

  @override
  String get selectOrganizationTitle => 'Choose an organization';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmBody =>
      'You\'ll need your email and password to sign in again.';

  @override
  String get noEventsYetTitle => 'No events yet';

  @override
  String get noEventsYetBody =>
      'Numbers appear once your app sends events with the SDK.';

  @override
  String get eventsPerDayTitle => 'Events per day';

  @override
  String get topScreensTitle => 'Top screens';

  @override
  String get topEventsTitle => 'Top events';

  @override
  String get seeEvents => 'See events';

  @override
  String get noDataForRange => 'Nothing in this period yet.';

  @override
  String changeUp(String percent) {
    return '↑ $percent%';
  }

  @override
  String changeDown(String percent) {
    return '↓ $percent%';
  }

  @override
  String durationMinSec(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String viewsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString views',
      one: '1 view',
    );
    return '$_temp0';
  }

  @override
  String usersCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString users',
      one: '1 user',
    );
    return '$_temp0';
  }

  @override
  String eventsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get searchEventsHint => 'Search user id, screen or property';

  @override
  String get allEventsFilter => 'All events';

  @override
  String get noMatchingEventsTitle => 'No matching events';

  @override
  String get noMatchingEventsBody => 'Try another filter or search.';

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get loadMoreFailed => 'Couldn\'t load more. Pull down to refresh.';

  @override
  String get searchUsersHint => 'Search user id or trait';

  @override
  String get usersFilterLabel => 'Which users';

  @override
  String filterAll(int count) {
    return 'All $count';
  }

  @override
  String filterKnown(int count) {
    return 'Known $count';
  }

  @override
  String filterNew(int count) {
    return 'New $count';
  }

  @override
  String get anonymousUser => 'Anonymous';

  @override
  String get noUsersTitle => 'No users yet';

  @override
  String get noUsersBody => 'People appear here once your app sends events.';

  @override
  String get noMatchingUsersTitle => 'No matching users';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get userTitle => 'User';

  @override
  String get firstSeenLabel => 'First seen';

  @override
  String get lastSeenLabel => 'Last seen';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get eventsLabel => 'Events';

  @override
  String get recentSessionsTitle => 'Recent sessions';

  @override
  String get noSessions => 'No sessions recorded yet.';

  @override
  String get userNotFound => 'This user no longer exists.';

  @override
  String get projectsMenuTitle => 'Projects and API keys';

  @override
  String projectsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString projects',
      one: '1 project',
      zero: 'No projects',
    );
    return '$_temp0';
  }

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsSubtitle =>
      'One project per app or website. Each has its own API key and data.';

  @override
  String get newProjectButton => 'New project';

  @override
  String get projectNameLabel => 'Project name';

  @override
  String get projectNameHint => 'Car App';

  @override
  String get platformWeb => 'Website';

  @override
  String get platformIos => 'iOS';

  @override
  String get platformAndroid => 'Android';

  @override
  String get platformFlutter => 'Flutter';

  @override
  String get platformOther => 'Other';

  @override
  String get timezoneHint => 'Asia/Kolkata';

  @override
  String get timezoneHelp => 'Days in charts are counted in this timezone.';

  @override
  String get createProjectButton => 'Create project';

  @override
  String activeKeysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active keys',
      one: '1 active key',
      zero: 'No active key',
    );
    return '$_temp0';
  }

  @override
  String get onlyAdminsCreateProjects =>
      'Only admins can create projects and manage API keys.';

  @override
  String get apiKeysTitle => 'API keys';

  @override
  String get newKeyButton => 'New key';

  @override
  String get keyNameLabel => 'Key name';

  @override
  String get keyNameHint => 'Android release';

  @override
  String get createKeyButton => 'Create key';

  @override
  String get keyActive => 'Active';

  @override
  String get keyRevoked => 'Revoked';

  @override
  String keyUsed(String when) {
    return 'used $when';
  }

  @override
  String get keyNeverUsed => 'never used';

  @override
  String get revokeKeyButton => 'Revoke';

  @override
  String get revokeKeyTitle => 'Revoke this key?';

  @override
  String revokeKeyBody(String name) {
    return 'Apps using \"$name\" stop sending events immediately. This can\'t be undone.';
  }

  @override
  String get keyCreatedTitle => 'Copy your API key now';

  @override
  String get keyCreatedBody =>
      'It is shown only once. If you lose it, create a new key and revoke this one.';

  @override
  String get copyButton => 'Copy';

  @override
  String get copiedMessage => 'Copied';

  @override
  String get doneButton => 'Done';

  @override
  String get noKeysYet => 'No API keys yet.';

  @override
  String get sdkSetupTitle => 'Add the SDK to your app';

  @override
  String get sdkStepDependency => '1. In pubspec.yaml';

  @override
  String get sdkStepInit => '2. In main.dart, with your API key';

  @override
  String get keysAdminOnly => 'Only admins can see and manage API keys.';

  @override
  String get createdLabel => 'Created';

  @override
  String get membersMenuTitle => 'Members and roles';

  @override
  String get membersTitle => 'Members';

  @override
  String get youLabel => 'You';

  @override
  String joinedOn(String date) {
    return 'Joined $date';
  }

  @override
  String get addMemberButton => 'Add member';

  @override
  String get addMemberTitle => 'Add a member';

  @override
  String get addMemberHelp =>
      'If this email has no account yet, one is created with the temporary password. Share it with them so they can sign in.';

  @override
  String get roleLabel => 'Role';

  @override
  String get roleHelp =>
      'Viewers only read. Analysts see all data and will create alerts. Admins also manage projects, API keys and members.';

  @override
  String get temporaryPasswordLabel => 'Temporary password';

  @override
  String get temporaryPasswordHint => 'Only needed for a new account';

  @override
  String get fullNameOptionalLabel => 'Name (optional)';

  @override
  String memberAdded(String email, String role) {
    return '$email added as $role';
  }

  @override
  String get changeRoleTitle => 'Change role';

  @override
  String roleChanged(String role) {
    return 'Role changed to $role';
  }

  @override
  String get removeMemberButton => 'Remove';

  @override
  String removeMemberTitle(String email) {
    return 'Remove $email?';
  }

  @override
  String get removeMemberBody =>
      'They lose access to this organization\'s data immediately. Their account itself is kept.';

  @override
  String get leaveOrganizationButton => 'Leave organization';

  @override
  String leaveOrganizationTitle(String organization) {
    return 'Leave $organization?';
  }

  @override
  String get leaveOrganizationBody =>
      'You lose access to its data. An admin can add you again later.';

  @override
  String memberActions(String email) {
    return 'Actions for $email';
  }

  @override
  String get membersLoadFailed => 'Couldn\'t load members';
}
