/// Raw data shown in the Events and Users tabs.
library;

Map<String, dynamic> _map(Object? value) => Map<String, dynamic>.from(value as Map);

DateTime _time(Object? value) => DateTime.parse(value as String).toLocal();

/// One event (`GET .../events`).
class EventItem {
  const EventItem({
    required this.id,
    required this.eventName,
    required this.distinctId,
    required this.occurredAt,
    required this.properties,
    this.personId,
    this.sessionId,
    this.screenName,
    this.path,
    this.os,
    this.browser,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) => EventItem(
        id: json['id'] as String,
        eventName: json['event_name'] as String,
        distinctId: json['distinct_id'] as String,
        personId: json['person_id'] as String?,
        sessionId: json['session_id'] as String?,
        occurredAt: _time(json['occurred_at']),
        screenName: json['screen_name'] as String?,
        path: json['path'] as String?,
        os: json['os'] as String?,
        browser: json['browser'] as String?,
        properties: _map(json['properties'] ?? const {}),
      );

  final String id;
  final String eventName;
  final String distinctId;
  final String? personId;
  final String? sessionId;
  final DateTime occurredAt;
  final String? screenName;
  final String? path;
  final String? os;
  final String? browser;
  final Map<String, dynamic> properties;

  /// Where it happened: screen for apps, path for websites.
  String? get location => screenName ?? path;

  /// Properties worth showing in a list, without the SDK's own `$...` keys.
  Map<String, dynamic> get visibleProperties =>
      Map.fromEntries(properties.entries.where((e) => !e.key.startsWith(r'$')));
}

class EventPage {
  const EventPage({required this.items, this.nextCursor});

  factory EventPage.fromJson(Map<String, dynamic> json) => EventPage(
        items: (json['items'] as List).map((e) => EventItem.fromJson(_map(e))).toList(),
        nextCursor: json['next_cursor'] as String?,
      );

  final List<EventItem> items;
  final String? nextCursor;
}

/// An event name seen in the project (`GET .../event-definitions`).
class EventDefinition {
  const EventDefinition({required this.eventName, required this.lastSeenAt});

  factory EventDefinition.fromJson(Map<String, dynamic> json) =>
      EventDefinition(eventName: json['event_name'] as String, lastSeenAt: _time(json['last_seen_at']));

  final String eventName;
  final DateTime lastSeenAt;
}

enum PersonFilter {
  all('all'),
  identified('identified'),
  newUsers('new');

  const PersonFilter(this.apiValue);

  final String apiValue;
}

/// An end user of the tracked app (`GET .../persons`).
class Person {
  const Person({
    required this.id,
    required this.distinctId,
    required this.properties,
    required this.isIdentified,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.eventCount,
    this.lastOs,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String,
        distinctId: json['distinct_id'] as String,
        properties: _map(json['properties'] ?? const {}),
        isIdentified: json['is_identified'] as bool,
        firstSeenAt: _time(json['first_seen_at']),
        lastSeenAt: _time(json['last_seen_at']),
        eventCount: json['event_count'] as int,
        lastOs: json['last_os'] as String?,
      );

  final String id;
  final String distinctId;
  final Map<String, dynamic> properties;
  final bool isIdentified;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final int eventCount;
  final String? lastOs;

  /// Traits set with identify(), without the SDK's own `$...` keys.
  Map<String, dynamic> get traits => Map.fromEntries(properties.entries.where((e) => !e.key.startsWith(r'$')));
}

class PersonCounts {
  const PersonCounts({required this.all, required this.identified, required this.newUsers});

  factory PersonCounts.fromJson(Map<String, dynamic> json) =>
      PersonCounts(all: json['all'] as int, identified: json['identified'] as int, newUsers: json['new'] as int);

  final int all;
  final int identified;
  final int newUsers;
}

class PersonPage {
  const PersonPage({required this.items, required this.total, required this.counts});

  factory PersonPage.fromJson(Map<String, dynamic> json) => PersonPage(
        items: (json['items'] as List).map((p) => Person.fromJson(_map(p))).toList(),
        total: json['total'] as int,
        counts: PersonCounts.fromJson(_map(json['counts'])),
      );

  final List<Person> items;
  final int total;
  final PersonCounts counts;
}

class SessionWithEvents {
  const SessionWithEvents({
    required this.id,
    required this.startedAt,
    required this.durationSeconds,
    required this.eventCount,
    required this.events,
    this.endedAt,
    this.entryPath,
    this.exitPath,
    this.os,
  });

  factory SessionWithEvents.fromJson(Map<String, dynamic> json) => SessionWithEvents(
        id: json['id'] as String,
        startedAt: _time(json['started_at']),
        endedAt: json['ended_at'] == null ? null : _time(json['ended_at']),
        durationSeconds: json['duration_seconds'] as int,
        eventCount: json['event_count'] as int,
        entryPath: json['entry_path'] as String?,
        exitPath: json['exit_path'] as String?,
        os: json['os'] as String?,
        events: (json['events'] as List).map((e) => EventItem.fromJson(_map(e))).toList(),
      );

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int eventCount;
  final String? entryPath;
  final String? exitPath;
  final String? os;

  /// Newest first.
  final List<EventItem> events;
}

/// One user with totals and recent sessions (`GET .../persons/{id}`).
class PersonDetail {
  const PersonDetail({required this.person, required this.sessionCount, required this.eventCount, required this.sessions});

  factory PersonDetail.fromJson(Map<String, dynamic> json) {
    final stats = _map(json['stats']);
    return PersonDetail(
      person: Person.fromJson(_map(json['person'])),
      sessionCount: stats['sessions'] as int,
      eventCount: stats['events'] as int,
      sessions: (json['sessions'] as List).map((s) => SessionWithEvents.fromJson(_map(s))).toList(),
    );
  }

  final Person person;
  final int sessionCount;
  final int eventCount;
  final List<SessionWithEvents> sessions;
}
