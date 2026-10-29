import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/workspace_models.dart';

class WorkspaceRepository {
  WorkspaceRepository(this._api);

  final ApiClient _api;

  Future<List<Project>> projects(String organizationId) => _api.get(
        '/orgs/$organizationId/projects',
        (data) => (data as List).map((p) => Project.fromJson(Map<String, dynamic>.from(p as Map))).toList(),
      );
}

final workspaceRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => WorkspaceRepository(ref.watch(apiClientProvider)),
);
