import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics Tracker'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'See what people do in your app, screen by screen.'**
  String get heroTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the email your organization registered with, or the one your admin added.'**
  String get signInSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@company.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get noAccountPrompt;

  /// No description provided for @createOrganizationLink.
  ///
  /// In en, this message translates to:
  /// **'Create an organization'**
  String get createOrganizationLink;

  /// No description provided for @joinTeamNote.
  ///
  /// In en, this message translates to:
  /// **'Joining a team? Your admin creates your account and gives you a temporary password.'**
  String get joinTeamNote;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your organization'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You become its admin. Analysts and viewers you add later see only this organization\'s data.'**
  String get registerSubtitle;

  /// No description provided for @organizationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get organizationNameLabel;

  /// No description provided for @organizationNameHint.
  ///
  /// In en, this message translates to:
  /// **'Acme Motors'**
  String get organizationNameHint;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameHint;

  /// No description provided for @workEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Work email'**
  String get workEmailLabel;

  /// No description provided for @nextStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Next steps'**
  String get nextStepsTitle;

  /// No description provided for @nextStepsBody.
  ///
  /// In en, this message translates to:
  /// **'1. Add a project for your app and copy its API key\n2. Add the SDK to your app\n3. Invite your team'**
  String get nextStepsBody;

  /// No description provided for @createOrganizationButton.
  ///
  /// In en, this message translates to:
  /// **'Create organization'**
  String get createOrganizationButton;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccountPrompt;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get validationPasswordLength;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters'**
  String validationMinLength(int min);

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @tabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// No description provided for @tabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get tabEvents;

  /// No description provided for @tabUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get tabUsers;

  /// No description provided for @tabAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get tabAlerts;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @rangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rangeToday;

  /// No description provided for @range7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get range7Days;

  /// No description provided for @range30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get range30Days;

  /// No description provided for @range90Days.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get range90Days;

  /// No description provided for @dateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRangeLabel;

  /// No description provided for @kpiActiveUsers.
  ///
  /// In en, this message translates to:
  /// **'Active users'**
  String get kpiActiveUsers;

  /// No description provided for @kpiEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get kpiEvents;

  /// No description provided for @kpiSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get kpiSessions;

  /// No description provided for @kpiAvgSession.
  ///
  /// In en, this message translates to:
  /// **'Avg. session'**
  String get kpiAvgSession;

  /// No description provided for @insightsPending.
  ///
  /// In en, this message translates to:
  /// **'Numbers appear here once the insights API is ready.'**
  String get insightsPending;

  /// No description provided for @projectDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectDetailsTitle;

  /// No description provided for @platformLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platformLabel;

  /// No description provided for @timezoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezoneLabel;

  /// No description provided for @activeKeysLabel.
  ///
  /// In en, this message translates to:
  /// **'Active API keys'**
  String get activeKeysLabel;

  /// No description provided for @selectProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a project'**
  String get selectProjectTitle;

  /// No description provided for @switchProject.
  ///
  /// In en, this message translates to:
  /// **'Switch project'**
  String get switchProject;

  /// No description provided for @noProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get noProjectsTitle;

  /// No description provided for @noProjectsBody.
  ///
  /// In en, this message translates to:
  /// **'An admin of this organization can add a project for each app or website.'**
  String get noProjectsBody;

  /// No description provided for @noOrganizationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No organization yet'**
  String get noOrganizationsTitle;

  /// No description provided for @noOrganizationsBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re not a member of any organization. Ask an admin to add you.'**
  String get noOrganizationsBody;

  /// No description provided for @loadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your workspace'**
  String get loadFailedTitle;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @eventsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'A live feed of every event your apps send, with search and filters.'**
  String get eventsComingSoon;

  /// No description provided for @usersComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Everyone who used your app, with their sessions and timeline.'**
  String get usersComingSoon;

  /// No description provided for @alertsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Rules that notify you when an event happens or crosses a threshold.'**
  String get alertsComingSoon;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @superAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'Super admin'**
  String get superAdminBadge;

  /// No description provided for @roleInOrganization.
  ///
  /// In en, this message translates to:
  /// **'{role} of {organization}'**
  String roleInOrganization(String role, String organization);

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Analyst'**
  String get roleAnalyst;

  /// No description provided for @roleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get roleViewer;

  /// No description provided for @organizationLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organizationLabel;

  /// No description provided for @switchOrganization.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchOrganization;

  /// No description provided for @selectOrganizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an organization'**
  String get selectOrganizationTitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @signOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need your email and password to sign in again.'**
  String get signOutConfirmBody;

  /// No description provided for @noEventsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYetTitle;

  /// No description provided for @noEventsYetBody.
  ///
  /// In en, this message translates to:
  /// **'Numbers appear once your app sends events with the SDK.'**
  String get noEventsYetBody;

  /// No description provided for @eventsPerDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Events per day'**
  String get eventsPerDayTitle;

  /// No description provided for @topScreensTitle.
  ///
  /// In en, this message translates to:
  /// **'Top screens'**
  String get topScreensTitle;

  /// No description provided for @topEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top events'**
  String get topEventsTitle;

  /// No description provided for @seeEvents.
  ///
  /// In en, this message translates to:
  /// **'See events'**
  String get seeEvents;

  /// No description provided for @noDataForRange.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this period yet.'**
  String get noDataForRange;

  /// No description provided for @changeUp.
  ///
  /// In en, this message translates to:
  /// **'↑ {percent}%'**
  String changeUp(String percent);

  /// No description provided for @changeDown.
  ///
  /// In en, this message translates to:
  /// **'↓ {percent}%'**
  String changeDown(String percent);

  /// No description provided for @durationMinSec.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String durationMinSec(int minutes, int seconds);

  /// No description provided for @viewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 view} other{{count} views}}'**
  String viewsCount(int count);

  /// No description provided for @usersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 user} other{{count} users}}'**
  String usersCount(int count);

  /// No description provided for @eventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String eventsCount(int count);

  /// No description provided for @searchEventsHint.
  ///
  /// In en, this message translates to:
  /// **'Search user id, screen or property'**
  String get searchEventsHint;

  /// No description provided for @allEventsFilter.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get allEventsFilter;

  /// No description provided for @noMatchingEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching events'**
  String get noMatchingEventsTitle;

  /// No description provided for @noMatchingEventsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or search.'**
  String get noMatchingEventsBody;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @loadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more. Pull down to refresh.'**
  String get loadMoreFailed;

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search user id or trait'**
  String get searchUsersHint;

  /// No description provided for @usersFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Which users'**
  String get usersFilterLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All {count}'**
  String filterAll(int count);

  /// No description provided for @filterKnown.
  ///
  /// In en, this message translates to:
  /// **'Known {count}'**
  String filterKnown(int count);

  /// No description provided for @filterNew.
  ///
  /// In en, this message translates to:
  /// **'New {count}'**
  String filterNew(int count);

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymousUser;

  /// No description provided for @noUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get noUsersTitle;

  /// No description provided for @noUsersBody.
  ///
  /// In en, this message translates to:
  /// **'People appear here once your app sends events.'**
  String get noUsersBody;

  /// No description provided for @noMatchingUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching users'**
  String get noMatchingUsersTitle;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String hoursAgo(int hours);

  /// No description provided for @userTitle.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userTitle;

  /// No description provided for @firstSeenLabel.
  ///
  /// In en, this message translates to:
  /// **'First seen'**
  String get firstSeenLabel;

  /// No description provided for @lastSeenLabel.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeenLabel;

  /// No description provided for @sessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionsLabel;

  /// No description provided for @eventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsLabel;

  /// No description provided for @recentSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get recentSessionsTitle;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions recorded yet.'**
  String get noSessions;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'This user no longer exists.'**
  String get userNotFound;

  /// No description provided for @projectsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects and API keys'**
  String get projectsMenuTitle;

  /// No description provided for @projectsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No projects} =1{1 project} other{{count} projects}}'**
  String projectsCount(int count);

  /// No description provided for @projectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// No description provided for @projectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One project per app or website. Each has its own API key and data.'**
  String get projectsSubtitle;

  /// No description provided for @newProjectButton.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get newProjectButton;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectNameLabel;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Car App'**
  String get projectNameHint;

  /// No description provided for @platformWeb.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get platformWeb;

  /// No description provided for @platformIos.
  ///
  /// In en, this message translates to:
  /// **'iOS'**
  String get platformIos;

  /// No description provided for @platformAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android'**
  String get platformAndroid;

  /// No description provided for @platformFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get platformFlutter;

  /// No description provided for @platformOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get platformOther;

  /// No description provided for @timezoneHint.
  ///
  /// In en, this message translates to:
  /// **'Asia/Kolkata'**
  String get timezoneHint;

  /// No description provided for @timezoneHelp.
  ///
  /// In en, this message translates to:
  /// **'Days in charts are counted in this timezone.'**
  String get timezoneHelp;

  /// No description provided for @createProjectButton.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProjectButton;

  /// No description provided for @activeKeysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active key} =1{1 active key} other{{count} active keys}}'**
  String activeKeysCount(int count);

  /// No description provided for @onlyAdminsCreateProjects.
  ///
  /// In en, this message translates to:
  /// **'Only admins can create projects and manage API keys.'**
  String get onlyAdminsCreateProjects;

  /// No description provided for @apiKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'API keys'**
  String get apiKeysTitle;

  /// No description provided for @newKeyButton.
  ///
  /// In en, this message translates to:
  /// **'New key'**
  String get newKeyButton;

  /// No description provided for @keyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Key name'**
  String get keyNameLabel;

  /// No description provided for @keyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Android release'**
  String get keyNameHint;

  /// No description provided for @createKeyButton.
  ///
  /// In en, this message translates to:
  /// **'Create key'**
  String get createKeyButton;

  /// No description provided for @keyActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get keyActive;

  /// No description provided for @keyRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get keyRevoked;

  /// No description provided for @keyUsed.
  ///
  /// In en, this message translates to:
  /// **'used {when}'**
  String keyUsed(String when);

  /// No description provided for @keyNeverUsed.
  ///
  /// In en, this message translates to:
  /// **'never used'**
  String get keyNeverUsed;

  /// No description provided for @revokeKeyButton.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revokeKeyButton;

  /// No description provided for @revokeKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this key?'**
  String get revokeKeyTitle;

  /// No description provided for @revokeKeyBody.
  ///
  /// In en, this message translates to:
  /// **'Apps using \"{name}\" stop sending events immediately. This can\'t be undone.'**
  String revokeKeyBody(String name);

  /// No description provided for @keyCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy your API key now'**
  String get keyCreatedTitle;

  /// No description provided for @keyCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'It is shown only once. If you lose it, create a new key and revoke this one.'**
  String get keyCreatedBody;

  /// No description provided for @copyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// No description provided for @copiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedMessage;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @noKeysYet.
  ///
  /// In en, this message translates to:
  /// **'No API keys yet.'**
  String get noKeysYet;

  /// No description provided for @sdkSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Add the SDK to your app'**
  String get sdkSetupTitle;

  /// No description provided for @sdkStepDependency.
  ///
  /// In en, this message translates to:
  /// **'1. In pubspec.yaml'**
  String get sdkStepDependency;

  /// No description provided for @sdkStepInit.
  ///
  /// In en, this message translates to:
  /// **'2. In main.dart, with your API key'**
  String get sdkStepInit;

  /// No description provided for @keysAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'Only admins can see and manage API keys.'**
  String get keysAdminOnly;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdLabel;

  /// No description provided for @membersMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Members and roles'**
  String get membersMenuTitle;

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersTitle;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @joinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedOn(String date);

  /// No description provided for @addMemberButton.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMemberButton;

  /// No description provided for @addMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a member'**
  String get addMemberTitle;

  /// No description provided for @addMemberHelp.
  ///
  /// In en, this message translates to:
  /// **'If this email has no account yet, one is created with the temporary password. Share it with them so they can sign in.'**
  String get addMemberHelp;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @roleHelp.
  ///
  /// In en, this message translates to:
  /// **'Viewers only read. Analysts see all data and will create alerts. Admins also manage projects, API keys and members.'**
  String get roleHelp;

  /// No description provided for @temporaryPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Temporary password'**
  String get temporaryPasswordLabel;

  /// No description provided for @temporaryPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Only needed for a new account'**
  String get temporaryPasswordHint;

  /// No description provided for @fullNameOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get fullNameOptionalLabel;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'{email} added as {role}'**
  String memberAdded(String email, String role);

  /// No description provided for @changeRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get changeRoleTitle;

  /// No description provided for @roleChanged.
  ///
  /// In en, this message translates to:
  /// **'Role changed to {role}'**
  String roleChanged(String role);

  /// No description provided for @removeMemberButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMemberButton;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {email}?'**
  String removeMemberTitle(String email);

  /// No description provided for @removeMemberBody.
  ///
  /// In en, this message translates to:
  /// **'They lose access to this organization\'s data immediately. Their account itself is kept.'**
  String get removeMemberBody;

  /// No description provided for @leaveOrganizationButton.
  ///
  /// In en, this message translates to:
  /// **'Leave organization'**
  String get leaveOrganizationButton;

  /// No description provided for @leaveOrganizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {organization}?'**
  String leaveOrganizationTitle(String organization);

  /// No description provided for @leaveOrganizationBody.
  ///
  /// In en, this message translates to:
  /// **'You lose access to its data. An admin can add you again later.'**
  String get leaveOrganizationBody;

  /// No description provided for @memberActions.
  ///
  /// In en, this message translates to:
  /// **'Actions for {email}'**
  String memberActions(String email);

  /// No description provided for @membersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load members'**
  String get membersLoadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
