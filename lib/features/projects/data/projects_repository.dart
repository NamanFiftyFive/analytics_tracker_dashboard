import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../workspace/domain/project_scope.dart';
import '../domain/project_models.dart';

/// Creating projects and managing their API keys (admin only on the backend).
class ProjectsRepository {
  ProjectsRepository(this._api);

  final ApiClient _api;

  static Map<String, dynamic> _map(Object? data) => Map<String, dynamic>.from(data as Map);

  Future<CreatedProject> createProject(
    String organizationId, {
    required String name,
    required ProjectPlatform platform,
    required String timezone,
  }) =>
      _api.post(
        '/orgs/$organizationId/projects',
        (data) => CreatedProject.fromJson(_map(data)),
        body: {'name': name, 'platform': platform.apiValue, 'timezone': timezone},
      );

  Future<List<ApiKey>> apiKeys(ProjectScope scope) => _api.get(
        '${scope.basePath}/api-keys',
        (data) => (data as List).map((k) => ApiKey.fromJson(_map(k))).toList(),
      );

  Future<CreatedApiKey> createApiKey(ProjectScope scope, String name) => _api.post(
        '${scope.basePath}/api-keys',
        (data) => CreatedApiKey.fromJson(_map(data)),
        body: {'name': name},
      );

  Future<ApiKey> revokeApiKey(ProjectScope scope, String keyId) =>
      _api.delete('${scope.basePath}/api-keys/$keyId', (data) => ApiKey.fromJson(_map(data)));
}

final projectsRepositoryProvider = Provider<ProjectsRepository>(
  (ref) => ProjectsRepository(ref.watch(apiClientProvider)),
);
