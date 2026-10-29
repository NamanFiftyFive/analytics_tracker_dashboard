import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/workspace_repository.dart';
import '../domain/workspace_models.dart';

/// Which organization the user picked (null = the first one). Kept in its own provider so it
/// survives the workspace reloading.
class SelectedOrganizationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String organizationId) => state = organizationId;
}

final selectedOrganizationProvider =
    NotifierProvider<SelectedOrganizationNotifier, String?>(SelectedOrganizationNotifier.new);

/// Which project the user picked (null = the first one). Survives reloads, e.g. after
/// creating a key, so the other tabs don't jump to another project.
class SelectedProjectNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? projectId) => state = projectId;
}

final selectedProjectProvider = NotifierProvider<SelectedProjectNotifier, String?>(SelectedProjectNotifier.new);

/// The organization and project the dashboard shows. Null when the user belongs to no
/// organization. Reloads when the signed-in user or the selected organization changes.
class WorkspaceController extends AsyncNotifier<Workspace?> {
  @override
  Future<Workspace?> build() async {
    final session = await ref.watch(authControllerProvider.future);
    final selectedId = ref.watch(selectedOrganizationProvider);
    final memberships = session?.memberships ?? const [];
    if (memberships.isEmpty) return null;

    final organization = memberships.where((m) => m.organizationId == selectedId).firstOrNull ?? memberships.first;
    final projects = await ref.read(workspaceRepositoryProvider).projects(organization.organizationId);
    // read, not watch: switching project only changes the selection, it doesn't refetch.
    final wanted = ref.read(selectedProjectProvider);
    final selected = projects.where((p) => p.id == wanted).firstOrNull ?? projects.firstOrNull;
    return Workspace(organization: organization, projects: projects, selectedProjectId: selected?.id);
  }

  void selectOrganization(String organizationId) {
    ref.read(selectedProjectProvider.notifier).select(null); // projects belong to the old organization
    ref.read(selectedOrganizationProvider.notifier).select(organizationId);
  }

  void selectProject(String projectId) {
    ref.read(selectedProjectProvider.notifier).select(projectId);
    final current = state.value;
    if (current != null) state = AsyncData(current.withProject(projectId));
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final workspaceControllerProvider = AsyncNotifierProvider<WorkspaceController, Workspace?>(WorkspaceController.new);
