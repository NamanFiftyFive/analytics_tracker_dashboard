import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workspace/application/organization_admin_provider.dart';
import '../../workspace/application/workspace_controller.dart';
import '../../workspace/domain/project_scope.dart';
import '../data/projects_repository.dart';
import '../domain/project_models.dart';

/// Admins (and super admins) create projects and manage keys; others only look.
final canManageProjectsProvider = Provider<bool>((ref) => ref.watch(isOrganizationAdminProvider));

/// A project's API keys, with create and revoke.
class ApiKeysController extends AsyncNotifier<List<ApiKey>> {
  ApiKeysController(this.scope);

  final ProjectScope scope;

  ProjectsRepository get _repository => ref.read(projectsRepositoryProvider);

  @override
  Future<List<ApiKey>> build() => _repository.apiKeys(scope);

  /// Returns the new key (full key shown once) and refreshes the list and the project counts.
  Future<CreatedApiKey> create(String name) async {
    final created = await _repository.createApiKey(scope, name);
    await _reload();
    return created;
  }

  Future<void> revoke(String keyId) async {
    await _repository.revokeApiKey(scope, keyId);
    await _reload();
  }

  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
    // "Active keys" on the project cards comes from the projects list.
    await ref.read(workspaceControllerProvider.notifier).reload();
  }
}

final apiKeysProvider =
    AsyncNotifierProvider.autoDispose.family<ApiKeysController, List<ApiKey>, ProjectScope>(ApiKeysController.new);
