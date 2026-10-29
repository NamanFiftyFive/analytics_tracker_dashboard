// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'एनालिटिक्स ट्रैकर';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get heroTitle =>
      'देखें कि लोग आपके ऐप में हर स्क्रीन पर क्या करते हैं।';

  @override
  String get signInTitle => 'साइन इन करें';

  @override
  String get signInSubtitle =>
      'वही ईमेल इस्तेमाल करें जिससे आपका संगठन रजिस्टर हुआ है, या जो आपके एडमिन ने जोड़ा है।';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get emailHint => 'you@company.com';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get passwordHint => 'कम से कम 8 अक्षर';

  @override
  String get signInButton => 'साइन इन करें';

  @override
  String get noAccountPrompt => 'पहली बार?';

  @override
  String get createOrganizationLink => 'संगठन बनाएं';

  @override
  String get joinTeamNote =>
      'किसी टीम से जुड़ रहे हैं? आपका एडमिन आपका खाता बनाकर आपको एक अस्थायी पासवर्ड देगा।';

  @override
  String get registerTitle => 'अपना संगठन बनाएं';

  @override
  String get registerSubtitle =>
      'आप इसके एडमिन होंगे। बाद में जोड़े गए एनालिस्ट और व्यूअर केवल इसी संगठन का डेटा देखेंगे।';

  @override
  String get organizationNameLabel => 'संगठन का नाम';

  @override
  String get organizationNameHint => 'Acme Motors';

  @override
  String get fullNameLabel => 'आपका नाम';

  @override
  String get fullNameHint => 'पूरा नाम';

  @override
  String get workEmailLabel => 'ऑफ़िस ईमेल';

  @override
  String get nextStepsTitle => 'आगे के कदम';

  @override
  String get nextStepsBody =>
      '1. अपने ऐप के लिए प्रोजेक्ट जोड़ें और उसकी API key कॉपी करें\n2. अपने ऐप में SDK जोड़ें\n3. अपनी टीम को जोड़ें';

  @override
  String get createOrganizationButton => 'संगठन बनाएं';

  @override
  String get haveAccountPrompt => 'पहले से खाता है?';

  @override
  String get signInLink => 'साइन इन करें';

  @override
  String get backToSignIn => 'साइन इन पर वापस जाएं';

  @override
  String get validationRequired => 'यह जानकारी ज़रूरी है';

  @override
  String get validationEmail => 'सही ईमेल पता लिखें';

  @override
  String get validationPasswordLength => 'कम से कम 8 अक्षर इस्तेमाल करें';

  @override
  String validationMinLength(int min) {
    return 'कम से कम $min अक्षर इस्तेमाल करें';
  }

  @override
  String get errorNetwork =>
      'सर्वर से कनेक्ट नहीं हो पा रहा। अपना इंटरनेट जांचें और फिर कोशिश करें।';

  @override
  String get errorUnexpected => 'कुछ गलत हो गया। कृपया फिर से कोशिश करें।';

  @override
  String get tabOverview => 'सारांश';

  @override
  String get tabEvents => 'इवेंट';

  @override
  String get tabUsers => 'यूज़र';

  @override
  String get tabAlerts => 'अलर्ट';

  @override
  String get tabMore => 'और';

  @override
  String get rangeToday => 'आज';

  @override
  String get range7Days => '7 दिन';

  @override
  String get range30Days => '30 दिन';

  @override
  String get range90Days => '90 दिन';

  @override
  String get dateRangeLabel => 'समय सीमा';

  @override
  String get kpiActiveUsers => 'सक्रिय यूज़र';

  @override
  String get kpiEvents => 'इवेंट';

  @override
  String get kpiSessions => 'सेशन';

  @override
  String get kpiAvgSession => 'औसत सेशन';

  @override
  String get insightsPending =>
      'इनसाइट्स API तैयार होने पर यहां आंकड़े दिखेंगे।';

  @override
  String get projectDetailsTitle => 'प्रोजेक्ट';

  @override
  String get platformLabel => 'प्लेटफ़ॉर्म';

  @override
  String get timezoneLabel => 'टाइमज़ोन';

  @override
  String get activeKeysLabel => 'सक्रिय API key';

  @override
  String get selectProjectTitle => 'प्रोजेक्ट चुनें';

  @override
  String get switchProject => 'प्रोजेक्ट बदलें';

  @override
  String get noProjectsTitle => 'अभी कोई प्रोजेक्ट नहीं';

  @override
  String get noProjectsBody =>
      'इस संगठन का एडमिन हर ऐप या वेबसाइट के लिए प्रोजेक्ट जोड़ सकता है।';

  @override
  String get noOrganizationsTitle => 'अभी कोई संगठन नहीं';

  @override
  String get noOrganizationsBody =>
      'आप किसी संगठन के सदस्य नहीं हैं। किसी एडमिन से आपको जोड़ने को कहें।';

  @override
  String get loadFailedTitle => 'आपका वर्कस्पेस लोड नहीं हो सका';

  @override
  String get comingSoonTitle => 'जल्द आ रहा है';

  @override
  String get eventsComingSoon =>
      'आपके ऐप से आने वाले हर इवेंट की लाइव सूची, खोज और फ़िल्टर के साथ।';

  @override
  String get usersComingSoon =>
      'आपके ऐप के सभी यूज़र, उनके सेशन और टाइमलाइन के साथ।';

  @override
  String get alertsComingSoon =>
      'नियम जो किसी इवेंट के होने या सीमा पार करने पर आपको सूचित करें।';

  @override
  String get moreTitle => 'और';

  @override
  String get superAdminBadge => 'सुपर एडमिन';

  @override
  String roleInOrganization(String role, String organization) {
    return '$organization में $role';
  }

  @override
  String get roleAdmin => 'एडमिन';

  @override
  String get roleAnalyst => 'एनालिस्ट';

  @override
  String get roleViewer => 'व्यूअर';

  @override
  String get organizationLabel => 'संगठन';

  @override
  String get switchOrganization => 'बदलें';

  @override
  String get selectOrganizationTitle => 'संगठन चुनें';

  @override
  String get appearanceTitle => 'दिखावट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get signOutButton => 'साइन आउट करें';

  @override
  String get signOutConfirmTitle => 'साइन आउट करें?';

  @override
  String get signOutConfirmBody =>
      'दोबारा साइन इन करने के लिए आपको ईमेल और पासवर्ड चाहिए होगा।';

  @override
  String get noEventsYetTitle => 'अभी कोई इवेंट नहीं';

  @override
  String get noEventsYetBody =>
      'SDK से आपके ऐप के इवेंट भेजते ही आंकड़े दिखने लगेंगे।';

  @override
  String get eventsPerDayTitle => 'प्रतिदिन इवेंट';

  @override
  String get topScreensTitle => 'सबसे ज़्यादा देखी गई स्क्रीन';

  @override
  String get topEventsTitle => 'मुख्य इवेंट';

  @override
  String get seeEvents => 'इवेंट देखें';

  @override
  String get noDataForRange => 'इस अवधि में अभी कुछ नहीं।';

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
    return '$minutes मि $seconds से';
  }

  @override
  String viewsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString बार देखा गया',
      one: '1 बार देखा गया',
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
      other: '$countString यूज़र',
      one: '1 यूज़र',
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
      other: '$countString इवेंट',
      one: '1 इवेंट',
    );
    return '$_temp0';
  }

  @override
  String get searchEventsHint => 'यूज़र आईडी, स्क्रीन या प्रॉपर्टी खोजें';

  @override
  String get allEventsFilter => 'सभी इवेंट';

  @override
  String get noMatchingEventsTitle => 'कोई मिलता-जुलता इवेंट नहीं';

  @override
  String get noMatchingEventsBody => 'कोई दूसरा फ़िल्टर या खोज आज़माएं।';

  @override
  String get todayLabel => 'आज';

  @override
  String get yesterdayLabel => 'कल';

  @override
  String get loadMoreFailed =>
      'और लोड नहीं हो सका। रीफ़्रेश करने के लिए नीचे खींचें।';

  @override
  String get searchUsersHint => 'यूज़र आईडी या जानकारी खोजें';

  @override
  String get usersFilterLabel => 'कौन से यूज़र';

  @override
  String filterAll(int count) {
    return 'सभी $count';
  }

  @override
  String filterKnown(int count) {
    return 'पहचाने गए $count';
  }

  @override
  String filterNew(int count) {
    return 'नए $count';
  }

  @override
  String get anonymousUser => 'अनाम';

  @override
  String get noUsersTitle => 'अभी कोई यूज़र नहीं';

  @override
  String get noUsersBody => 'आपके ऐप से इवेंट आते ही लोग यहां दिखेंगे।';

  @override
  String get noMatchingUsersTitle => 'कोई मिलता-जुलता यूज़र नहीं';

  @override
  String get justNow => 'अभी';

  @override
  String minutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String get userTitle => 'यूज़र';

  @override
  String get firstSeenLabel => 'पहली बार देखा';

  @override
  String get lastSeenLabel => 'आख़िरी बार देखा';

  @override
  String get sessionsLabel => 'सेशन';

  @override
  String get eventsLabel => 'इवेंट';

  @override
  String get recentSessionsTitle => 'हाल के सेशन';

  @override
  String get noSessions => 'अभी कोई सेशन रिकॉर्ड नहीं हुआ।';

  @override
  String get userNotFound => 'यह यूज़र अब मौजूद नहीं है।';

  @override
  String get projectsMenuTitle => 'प्रोजेक्ट और API key';

  @override
  String projectsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString प्रोजेक्ट',
      one: '1 प्रोजेक्ट',
      zero: 'कोई प्रोजेक्ट नहीं',
    );
    return '$_temp0';
  }

  @override
  String get projectsTitle => 'प्रोजेक्ट';

  @override
  String get projectsSubtitle =>
      'हर ऐप या वेबसाइट के लिए एक प्रोजेक्ट। हर एक की अपनी API key और डेटा।';

  @override
  String get newProjectButton => 'नया प्रोजेक्ट';

  @override
  String get projectNameLabel => 'प्रोजेक्ट का नाम';

  @override
  String get projectNameHint => 'Car App';

  @override
  String get platformWeb => 'वेबसाइट';

  @override
  String get platformIos => 'iOS';

  @override
  String get platformAndroid => 'Android';

  @override
  String get platformFlutter => 'Flutter';

  @override
  String get platformOther => 'अन्य';

  @override
  String get timezoneHint => 'Asia/Kolkata';

  @override
  String get timezoneHelp =>
      'चार्ट में दिन इसी टाइमज़ोन के हिसाब से गिने जाते हैं।';

  @override
  String get createProjectButton => 'प्रोजेक्ट बनाएं';

  @override
  String activeKeysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सक्रिय key',
      one: '1 सक्रिय key',
      zero: 'कोई सक्रिय key नहीं',
    );
    return '$_temp0';
  }

  @override
  String get onlyAdminsCreateProjects =>
      'केवल एडमिन प्रोजेक्ट बना सकते हैं और API key संभाल सकते हैं।';

  @override
  String get apiKeysTitle => 'API key';

  @override
  String get newKeyButton => 'नई key';

  @override
  String get keyNameLabel => 'Key का नाम';

  @override
  String get keyNameHint => 'Android release';

  @override
  String get createKeyButton => 'Key बनाएं';

  @override
  String get keyActive => 'सक्रिय';

  @override
  String get keyRevoked => 'रद्द';

  @override
  String keyUsed(String when) {
    return 'इस्तेमाल: $when';
  }

  @override
  String get keyNeverUsed => 'कभी इस्तेमाल नहीं हुई';

  @override
  String get revokeKeyButton => 'रद्द करें';

  @override
  String get revokeKeyTitle => 'यह key रद्द करें?';

  @override
  String revokeKeyBody(String name) {
    return '\"$name\" इस्तेमाल करने वाले ऐप तुरंत इवेंट भेजना बंद कर देंगे। इसे वापस नहीं किया जा सकता।';
  }

  @override
  String get keyCreatedTitle => 'अपनी API key अभी कॉपी करें';

  @override
  String get keyCreatedBody =>
      'यह केवल एक बार दिखाई जाती है। खो जाए तो नई key बनाएं और इसे रद्द करें।';

  @override
  String get copyButton => 'कॉपी करें';

  @override
  String get copiedMessage => 'कॉपी हो गया';

  @override
  String get doneButton => 'हो गया';

  @override
  String get noKeysYet => 'अभी कोई API key नहीं।';

  @override
  String get sdkSetupTitle => 'अपने ऐप में SDK जोड़ें';

  @override
  String get sdkStepDependency => '1. pubspec.yaml में';

  @override
  String get sdkStepInit => '2. main.dart में, अपनी API key के साथ';

  @override
  String get keysAdminOnly => 'केवल एडमिन API key देख और संभाल सकते हैं।';

  @override
  String get createdLabel => 'बनाया गया';

  @override
  String get membersMenuTitle => 'सदस्य और भूमिकाएं';

  @override
  String get membersTitle => 'सदस्य';

  @override
  String get youLabel => 'आप';

  @override
  String joinedOn(String date) {
    return '$date को जुड़े';
  }

  @override
  String get addMemberButton => 'सदस्य जोड़ें';

  @override
  String get addMemberTitle => 'सदस्य जोड़ें';

  @override
  String get addMemberHelp =>
      'अगर इस ईमेल का खाता नहीं है, तो अस्थायी पासवर्ड से नया खाता बनेगा। साइन इन के लिए यह पासवर्ड उन्हें बताएं।';

  @override
  String get roleLabel => 'भूमिका';

  @override
  String get roleHelp =>
      'व्यूअर केवल देख सकते हैं। एनालिस्ट पूरा डेटा देखते हैं और अलर्ट बनाएंगे। एडमिन प्रोजेक्ट, API key और सदस्य भी संभालते हैं।';

  @override
  String get temporaryPasswordLabel => 'अस्थायी पासवर्ड';

  @override
  String get temporaryPasswordHint => 'केवल नए खाते के लिए ज़रूरी';

  @override
  String get fullNameOptionalLabel => 'नाम (वैकल्पिक)';

  @override
  String memberAdded(String email, String role) {
    return '$email को $role के रूप में जोड़ा गया';
  }

  @override
  String get changeRoleTitle => 'भूमिका बदलें';

  @override
  String roleChanged(String role) {
    return 'भूमिका बदलकर $role की गई';
  }

  @override
  String get removeMemberButton => 'हटाएं';

  @override
  String removeMemberTitle(String email) {
    return '$email को हटाएं?';
  }

  @override
  String get removeMemberBody =>
      'वे इस संगठन का डेटा तुरंत नहीं देख पाएंगे। उनका खाता बना रहेगा।';

  @override
  String get leaveOrganizationButton => 'संगठन छोड़ें';

  @override
  String leaveOrganizationTitle(String organization) {
    return '$organization छोड़ें?';
  }

  @override
  String get leaveOrganizationBody =>
      'आप इसका डेटा नहीं देख पाएंगे। कोई एडमिन आपको बाद में फिर जोड़ सकता है।';

  @override
  String memberActions(String email) {
    return '$email के लिए विकल्प';
  }

  @override
  String get membersLoadFailed => 'सदस्य लोड नहीं हो सके';
}
