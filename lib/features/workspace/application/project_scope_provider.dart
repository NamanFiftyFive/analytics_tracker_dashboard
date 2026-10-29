import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/project_scope.dart';
import 'workspace_controller.dart';

/// The project currently selected in the workspace, or null (still loading, no organization,
/// or no project). Overview, Events and Users all read their data for this project.
final projectScopeProvider = Provider<ProjectScope?>((ref) {
  final workspace = ref.watch(workspaceControllerProvider).value;
  final project = workspace?.selectedProject;
  if (workspace == null || project == null) return null;
  return ProjectScope(organizationId: workspace.organization.organizationId, projectId: project.id);
});
