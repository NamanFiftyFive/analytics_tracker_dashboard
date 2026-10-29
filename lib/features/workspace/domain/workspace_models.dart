import '../../auth/domain/auth_models.dart';

/// A tracked app or website (`GET /orgs/{org_id}/projects`).
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.platform,
    required this.timezone,
    required this.activeApiKeys,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        platform: json['platform'] as String,
        timezone: json['timezone'] as String,
        activeApiKeys: json['active_api_keys'] as int? ?? 0,
      );

  final String id;
  final String name;
  final String platform;
  final String timezone;
  final int activeApiKeys;
}

/// What the dashboard is looking at: one organization and (optionally) one of its projects.
class Workspace {
  const Workspace({required this.organization, required this.projects, this.selectedProjectId});

  final Membership organization;
  final List<Project> projects;
  final String? selectedProjectId;

  Project? get selectedProject =>
      projects.where((p) => p.id == selectedProjectId).firstOrNull ?? projects.firstOrNull;

  Workspace withProject(String projectId) =>
      Workspace(organization: organization, projects: projects, selectedProjectId: projectId);
}
