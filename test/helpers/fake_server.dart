import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// What a fake route answers.
class FakeResponse {
  const FakeResponse(this.status, this.body);

  /// {"status": <code>, "data": data}, like the real backend.
  factory FakeResponse.ok(Object? data, [int status = 200]) => FakeResponse(status, {'status': status, 'data': data});

  /// {"status": <code>, "error": message}, like the real backend.
  factory FakeResponse.error(int status, String message) => FakeResponse(status, {'status': status, 'error': message});

  final int status;
  final Object? body;
}

typedef FakeHandler = FakeResponse Function(RequestOptions request);

/// A pretend backend for tests, plugged into Dio as its HTTP adapter. Routes are keyed by
/// "METHOD /path" (path relative to the base URL); every request is recorded.
class FakeServer implements HttpClientAdapter {
  final _routes = <String, FakeHandler>{};
  final requests = <RequestOptions>[];

  /// Answer every matching request with [handler].
  void on(String method, String path, FakeHandler handler) => _routes['$method $path'] = handler;

  /// Answer with these responses in order, repeating the last one.
  void sequence(String method, String path, List<FakeResponse> responses) {
    var index = 0;
    on(method, path, (_) => responses[index < responses.length - 1 ? index++ : index]);
  }

  /// Simulate no network for this route.
  void offline(String method, String path) =>
      on(method, path, (_) => throw const SocketException('Network is unreachable'));

  List<RequestOptions> calls(String method, String path) =>
      requests.where((r) => r.method == method && r.path == path).toList();

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final handler = _routes['${options.method} ${options.path}'];
    final FakeResponse response;
    try {
      response = handler?.call(options) ?? FakeResponse.error(404, 'No fake route for ${options.method} ${options.path}');
    } on SocketException catch (error) {
      throw DioException.connectionError(requestOptions: options, reason: error.message, error: error);
    }
    return ResponseBody.fromString(
      jsonEncode(response.body),
      response.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// ── Sample backend data ──────────────────────────────────────────────────────

Map<String, Object?> tokensJson({String access = 'access-1', String refresh = 'refresh-1'}) =>
    {'access_token': access, 'refresh_token': refresh, 'token_type': 'bearer', 'expires_in': 900};

Map<String, Object?> membershipJson({
  String id = 'org-1',
  String name = 'One',
  String role = 'admin',
}) =>
    {'id': id, 'name': name, 'slug': name.toLowerCase(), 'plan': 'free', 'is_active': true, 'role': role};

Map<String, Object?> meJson({
  String email = 'admin@example.com',
  bool superadmin = false,
  List<Map<String, Object?>>? organizations,
}) =>
    {
      'user': {
        'id': 'user-1',
        'email': email,
        'full_name': 'Test Admin',
        'is_active': true,
        'is_superadmin': superadmin,
        'last_login_at': null,
        'created_at': '2026-10-20T10:00:00Z',
      },
      'organizations': organizations ?? [membershipJson()],
    };

Map<String, Object?> projectJson({String id = 'proj-1', String name = 'Tracker Test App', String platform = 'flutter'}) =>
    {
      'id': id,
      'organization_id': 'org-1',
      'name': name,
      'platform': platform,
      'timezone': 'Asia/Kolkata',
      'allowed_origins': <String>[],
      'created_at': '2026-10-20T10:00:00Z',
      'active_api_keys': 1,
    };

/// A server where sign-in, refresh, me and projects all work.
FakeServer happyServer({List<Map<String, Object?>>? projects, Map<String, Object?>? me}) {
  final server = FakeServer();
  server.on('POST', '/auth/login', (_) => FakeResponse.ok(tokensJson()));
  server.on('POST', '/auth/register', (_) => FakeResponse.ok(tokensJson(), 201));
  server.on('POST', '/auth/refresh', (_) => FakeResponse.ok(tokensJson(access: 'access-2', refresh: 'refresh-2')));
  server.on('POST', '/auth/logout', (_) => FakeResponse.ok(null));
  server.on('GET', '/auth/me', (_) => FakeResponse.ok(me ?? meJson()));
  server.on('GET', '/orgs/org-1/projects', (_) => FakeResponse.ok(projects ?? [projectJson()]));
  server.on('GET', '$projectPath/insights/overview', (_) => FakeResponse.ok(overviewJson()));
  server.on('GET', '$projectPath/events', (_) => FakeResponse.ok(eventPageJson()));
  server.on('GET', '$projectPath/event-definitions', (_) => FakeResponse.ok(definitionsJson()));
  server.on('GET', '$projectPath/persons', (_) => FakeResponse.ok(personPageJson()));
  server.on('GET', '$projectPath/persons/person-1', (_) => FakeResponse.ok(personDetailJson()));
  server.on('GET', '$projectPath/api-keys', (_) => FakeResponse.ok(apiKeysJson()));
  server.on('POST', '$projectPath/api-keys', (request) =>
      FakeResponse.ok(createdKeyJson(name: (request.data as Map)['name'] as String), 201));
  server.on('DELETE', '$projectPath/api-keys/key-1', (_) => FakeResponse.ok(apiKeyJson(id: 'key-1', active: false)));
  server.on('POST', '/orgs/org-1/projects', (request) {
    final body = request.data as Map;
    return FakeResponse.ok({
      'project': projectJson(id: 'proj-new', name: body['name'] as String, platform: body['platform'] as String),
      'api_key': createdKeyJson(name: 'Default key', id: 'key-new'),
    }, 201);
  });
  server.on('GET', '/orgs/org-1/members', (_) => FakeResponse.ok(membersJson()));
  server.on('POST', '/orgs/org-1/members', (request) {
    final body = request.data as Map;
    return FakeResponse.ok(
      memberJson(id: 'user-new', email: body['email'] as String, name: body['full_name'] as String?, role: body['role'] as String),
      201,
    );
  });
  server.on('PATCH', '/orgs/org-1/members/user-2', (request) =>
      FakeResponse.ok(memberJson(id: 'user-2', email: 'riya@example.com', name: 'Riya Shah', role: (request.data as Map)['role'] as String)));
  server.on('DELETE', '/orgs/org-1/members/user-2', (_) => FakeResponse.ok(null));
  return server;
}

// ── Members (org-1; user-1 is the signed-in admin) ───────────────────────────

Map<String, Object?> memberJson({required String id, required String email, String? name, String role = 'viewer'}) => {
      'user_id': id,
      'email': email,
      'full_name': name,
      'role': role,
      'joined_at': '2026-10-01T10:00:00Z',
    };

List<Map<String, Object?>> membersJson() => [
      memberJson(id: 'user-1', email: 'admin@example.com', name: 'Test Admin', role: 'admin'),
      memberJson(id: 'user-2', email: 'riya@example.com', name: 'Riya Shah', role: 'analyst'),
      memberJson(id: 'user-3', email: 'viewer@example.com'),
    ];

// ── Projects and API keys ────────────────────────────────────────────────────

const newFullKey = 'pk_live_NEWKEY1234567890abcdefghijklmnopqrstuv';

Map<String, Object?> apiKeyJson({String id = 'key-1', String name = 'Default key', bool active = true, int? usedMinutesAgo = 2}) => {
      'id': id,
      'name': name,
      'key_prefix': 'pk_live_${id.substring(0, 4)}',
      'is_active': active,
      'last_used_at': usedMinutesAgo == null ? null : isoMinutesAgo(usedMinutesAgo),
      'revoked_at': active ? null : isoMinutesAgo(1),
      'created_at': isoMinutesAgo(60 * 24),
    };

List<Map<String, Object?>> apiKeysJson() => [
      apiKeyJson(),
      apiKeyJson(id: 'key-old', name: 'Old Android key', active: false, usedMinutesAgo: null),
    ];

Map<String, Object?> createdKeyJson({required String name, String id = 'key-2'}) =>
    {...apiKeyJson(id: id, name: name, usedMinutesAgo: null), 'key': newFullKey};

// ── Analytics data (project proj-1 of org-1) ─────────────────────────────────

const projectPath = '/orgs/org-1/projects/proj-1';

String isoMinutesAgo(int minutes) => DateTime.now().toUtc().subtract(Duration(minutes: minutes)).toIso8601String();

Map<String, Object?> kpiJson(num value, num previous) => {
      'value': value,
      'previous': previous,
      'change_percent': previous == 0 ? null : double.parse(((value - previous) / previous * 100).toStringAsFixed(1)),
    };

Map<String, Object?> overviewJson({bool empty = false}) {
  final today = DateTime.now();
  final perDay = [820, 940, 1010, 760, 1180, 1340, 1520];
  return {
    'range': '7d',
    'timezone': 'Asia/Kolkata',
    'start': isoMinutesAgo(7 * 24 * 60),
    'end': isoMinutesAgo(0),
    'kpis': {
      'active_users': empty ? kpiJson(0, 0) : kpiJson(248, 221),
      'events': empty ? kpiJson(0, 0) : kpiJson(7570, 7010),
      'sessions': empty ? kpiJson(0, 0) : kpiJson(612, 631),
      'avg_session_seconds': empty ? kpiJson(0, 0) : kpiJson(252, 240),
    },
    'events_per_day': [
      for (var i = 0; i < 7; i++)
        {
          'day': today.subtract(Duration(days: 6 - i)).toIso8601String().substring(0, 10),
          'events': empty ? 0 : perDay[i],
          'users': empty ? 0 : 30 + i,
        },
    ],
    'top_screens': empty
        ? []
        : [
            {'screen_name': 'CarList', 'views': 2140, 'users': 180},
            {'screen_name': 'CarDetail', 'views': 1705, 'users': 150},
          ],
    'top_events': empty
        ? []
        : [
            {'event_name': 'test_drive_booked', 'count': 41, 'users': 38},
            {'event_name': 'car_liked', 'count': 33, 'users': 20},
          ],
  };
}

Map<String, Object?> eventJson({
  required String id,
  required String name,
  String distinctId = 'customer_1042',
  String? personId = 'person-1',
  int minutesAgo = 5,
  String? screen = 'CarDetail',
  Map<String, Object?> properties = const {},
}) =>
    {
      'id': id,
      'event_name': name,
      'distinct_id': distinctId,
      'person_id': personId,
      'session_id': 'session-1',
      'occurred_at': isoMinutesAgo(minutesAgo),
      'screen_name': screen,
      'path': null,
      'platform': 'flutter',
      'os': 'Android 14',
      'browser': null,
      'device_type': 'mobile',
      'app_version': '2.3.1',
      'country': 'IN',
      'properties': properties,
    };

Map<String, Object?> eventPageJson({List<Map<String, Object?>>? items, String? nextCursor}) => {
      'items': items ??
          [
            eventJson(id: 'e2', name: 'test_drive_booked', minutesAgo: 2, properties: {'model': 'Nexon EV', 'showroom': 'Baner'}),
            eventJson(id: 'e1', name: 'car_liked', distinctId: 'anon-7f3a', personId: 'person-2', minutesAgo: 9, properties: {'model': 'Creta'}),
          ],
      'next_cursor': nextCursor,
    };

List<Map<String, Object?>> definitionsJson() => [
      {'event_name': 'test_drive_booked', 'first_seen_at': isoMinutesAgo(600), 'last_seen_at': isoMinutesAgo(2)},
      {'event_name': 'car_liked', 'first_seen_at': isoMinutesAgo(600), 'last_seen_at': isoMinutesAgo(9)},
    ];

Map<String, Object?> personJson({
  String id = 'person-1',
  String distinctId = 'customer_1042',
  Map<String, Object?> properties = const {'city': 'Pune', 'plan': 'premium', r'$anon_distinct_id': 'anon-a612'},
  int eventCount = 186,
  int lastSeenMinutesAgo = 2,
}) =>
    {
      'id': id,
      'distinct_id': distinctId,
      'properties': properties,
      'is_identified': properties.isNotEmpty,
      'first_seen_at': isoMinutesAgo(10 * 24 * 60),
      'last_seen_at': isoMinutesAgo(lastSeenMinutesAgo),
      'event_count': eventCount,
      'last_os': 'Android 14',
    };

Map<String, Object?> personPageJson({List<Map<String, Object?>>? items, int? total}) {
  final list = items ??
      [
        personJson(),
        personJson(id: 'person-2', distinctId: 'anon-7f3a', properties: const {}, eventCount: 12, lastSeenMinutesAgo: 9),
      ];
  return {
    'items': list,
    'total': total ?? list.length,
    'limit': 50,
    'offset': 0,
    'counts': {'all': 3, 'identified': 1, 'new': 2},
  };
}

Map<String, Object?> personDetailJson() => {
      'person': personJson(),
      'stats': {'sessions': 14, 'events': 186},
      'sessions': [
        {
          'id': 'session-1',
          'started_at': isoMinutesAgo(10),
          'ended_at': isoMinutesAgo(5),
          'duration_seconds': 300,
          'event_count': 3,
          'entry_path': 'Home',
          'exit_path': 'BookTestDrive',
          'os': 'Android 14',
          'app_version': '2.3.1',
          'events': [
            eventJson(id: 's3', name: 'test_drive_booked', minutesAgo: 5, screen: 'BookTestDrive', properties: {'model': 'Nexon EV'}),
            eventJson(id: 's2', name: r'$screen', minutesAgo: 7, screen: 'CarDetail'),
            eventJson(id: 's1', name: r'$app_open', minutesAgo: 10, screen: 'Home'),
          ],
        },
      ],
    };
