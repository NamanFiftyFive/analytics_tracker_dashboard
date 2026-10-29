/// Which project a query is about. Every analytics API lives under
/// /orgs/{organizationId}/projects/{projectId}/...
class ProjectScope {
  const ProjectScope({required this.organizationId, required this.projectId});

  final String organizationId;
  final String projectId;

  String get basePath => '/orgs/$organizationId/projects/$projectId';

  @override
  bool operator ==(Object other) =>
      other is ProjectScope && other.organizationId == organizationId && other.projectId == projectId;

  @override
  int get hashCode => Object.hash(organizationId, projectId);
}
