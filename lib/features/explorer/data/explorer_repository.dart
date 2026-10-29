import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../workspace/domain/project_scope.dart';
import '../domain/explorer_models.dart';

/// Read-only access to a project's raw events and users.
class ExplorerRepository {
  ExplorerRepository(this._api);

  final ApiClient _api;

  static Map<String, dynamic> _map(Object? data) => Map<String, dynamic>.from(data as Map);

  Future<EventPage> events(
    ProjectScope scope, {
    String? eventName,
    String? personId,
    String? search,
    String? cursor,
    int limit = 50,
  }) =>
      _api.get(
        '${scope.basePath}/events',
        (data) => EventPage.fromJson(_map(data)),
        query: {
          'limit': limit,
          'event': ?eventName,
          'person_id': ?personId,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          'cursor': ?cursor,
        },
      );

  Future<List<EventDefinition>> eventDefinitions(ProjectScope scope) => _api.get(
        '${scope.basePath}/event-definitions',
        (data) => (data as List).map((d) => EventDefinition.fromJson(_map(d))).toList(),
      );

  Future<PersonPage> persons(
    ProjectScope scope, {
    PersonFilter filter = PersonFilter.all,
    String? search,
    int limit = 50,
    int offset = 0,
  }) =>
      _api.get(
        '${scope.basePath}/persons',
        (data) => PersonPage.fromJson(_map(data)),
        query: {
          'filter': filter.apiValue,
          'limit': limit,
          'offset': offset,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );

  Future<PersonDetail> person(ProjectScope scope, String personId) =>
      _api.get('${scope.basePath}/persons/$personId', (data) => PersonDetail.fromJson(_map(data)));
}

final explorerRepositoryProvider = Provider<ExplorerRepository>(
  (ref) => ExplorerRepository(ref.watch(apiClientProvider)),
);
