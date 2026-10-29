import '../../workspace/domain/workspace_models.dart';

/// Platforms a project can be (same values as the backend).
enum ProjectPlatform {
  flutter('flutter'),
  android('android'),
  ios('ios'),
  web('web'),
  other('other');

  const ProjectPlatform(this.apiValue);

  final String apiValue;

  static ProjectPlatform parse(String value) =>
      ProjectPlatform.values.firstWhere((p) => p.apiValue == value, orElse: () => ProjectPlatform.other);
}

DateTime? _optionalTime(Object? value) => value == null ? null : DateTime.parse(value as String).toLocal();

/// A project API key as listed: only its visible prefix, never the full key.
class ApiKey {
  const ApiKey({
    required this.id,
    required this.name,
    required this.keyPrefix,
    required this.isActive,
    required this.createdAt,
    this.lastUsedAt,
    this.revokedAt,
  });

  factory ApiKey.fromJson(Map<String, dynamic> json) => ApiKey(
        id: json['id'] as String,
        name: json['name'] as String,
        keyPrefix: json['key_prefix'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        lastUsedAt: _optionalTime(json['last_used_at']),
        revokedAt: _optionalTime(json['revoked_at']),
      );

  final String id;
  final String name;
  final String keyPrefix;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;
}

/// A key right after creation: the only time the full key is available.
class CreatedApiKey {
  const CreatedApiKey({required this.apiKey, required this.key});

  factory CreatedApiKey.fromJson(Map<String, dynamic> json) =>
      CreatedApiKey(apiKey: ApiKey.fromJson(json), key: json['key'] as String);

  final ApiKey apiKey;

  /// `pk_live_…`: show it once, then it's gone.
  final String key;
}

/// `POST /orgs/{id}/projects` returns the project and its first key.
class CreatedProject {
  const CreatedProject({required this.project, required this.firstKey});

  factory CreatedProject.fromJson(Map<String, dynamic> json) => CreatedProject(
        project: Project.fromJson(Map<String, dynamic>.from(json['project'] as Map)),
        firstKey: CreatedApiKey.fromJson(Map<String, dynamic>.from(json['api_key'] as Map)),
      );

  final Project project;
  final CreatedApiKey firstKey;
}
