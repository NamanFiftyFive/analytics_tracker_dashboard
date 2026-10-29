/// `GET .../insights/overview` response.
library;

enum OverviewRange {
  today('today'),
  days7('7d'),
  days30('30d'),
  days90('90d');

  const OverviewRange(this.apiValue);

  final String apiValue;
}

class Kpi {
  const Kpi({required this.value, required this.previous, this.changePercent});

  factory Kpi.fromJson(Map<String, dynamic> json) => Kpi(
        value: (json['value'] as num).toDouble(),
        previous: (json['previous'] as num).toDouble(),
        changePercent: (json['change_percent'] as num?)?.toDouble(),
      );

  final double value;
  final double previous;

  /// Null when the previous period was 0 (no meaningful percentage).
  final double? changePercent;
}

class DayPoint {
  const DayPoint({required this.day, required this.events, required this.users});

  factory DayPoint.fromJson(Map<String, dynamic> json) =>
      DayPoint(day: DateTime.parse(json['day'] as String), events: json['events'] as int, users: json['users'] as int);

  final DateTime day;
  final int events;
  final int users;
}

class TopScreen {
  const TopScreen({required this.screenName, required this.views, required this.users});

  factory TopScreen.fromJson(Map<String, dynamic> json) =>
      TopScreen(screenName: json['screen_name'] as String, views: json['views'] as int, users: json['users'] as int);

  final String screenName;
  final int views;
  final int users;
}

class TopEvent {
  const TopEvent({required this.eventName, required this.count, required this.users});

  factory TopEvent.fromJson(Map<String, dynamic> json) =>
      TopEvent(eventName: json['event_name'] as String, count: json['count'] as int, users: json['users'] as int);

  final String eventName;
  final int count;
  final int users;
}

class Overview {
  const Overview({
    required this.activeUsers,
    required this.events,
    required this.sessions,
    required this.avgSessionSeconds,
    required this.eventsPerDay,
    required this.topScreens,
    required this.topEvents,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    final kpis = Map<String, dynamic>.from(json['kpis'] as Map);
    Kpi kpi(String key) => Kpi.fromJson(Map<String, dynamic>.from(kpis[key] as Map));
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List).map((e) => parse(Map<String, dynamic>.from(e as Map))).toList();
    return Overview(
      activeUsers: kpi('active_users'),
      events: kpi('events'),
      sessions: kpi('sessions'),
      avgSessionSeconds: kpi('avg_session_seconds'),
      eventsPerDay: list('events_per_day', DayPoint.fromJson),
      topScreens: list('top_screens', TopScreen.fromJson),
      topEvents: list('top_events', TopEvent.fromJson),
    );
  }

  final Kpi activeUsers;
  final Kpi events;
  final Kpi sessions;
  final Kpi avgSessionSeconds;
  final List<DayPoint> eventsPerDay;
  final List<TopScreen> topScreens;
  final List<TopEvent> topEvents;

  bool get isEmpty => events.value == 0;
}
