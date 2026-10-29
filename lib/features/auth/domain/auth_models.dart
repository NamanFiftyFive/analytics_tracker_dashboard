/// Shapes returned by the backend's /auth endpoints (inside the response's `data`).
library;

enum MemberRole {
  admin,
  analyst,
  viewer;

  static MemberRole parse(String value) =>
      MemberRole.values.firstWhere((r) => r.name == value, orElse: () => MemberRole.viewer);
}

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken, required this.expiresIn});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn: json['expires_in'] as int,
      );

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.isSuperadmin,
    this.fullName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String?,
        isSuperadmin: json['is_superadmin'] as bool? ?? false,
      );

  final String id;
  final String email;
  final String? fullName;
  final bool isSuperadmin;

  String get displayName => (fullName?.trim().isNotEmpty ?? false) ? fullName!.trim() : email;
}

/// An organization the user belongs to, with their role in it.
class Membership {
  const Membership({
    required this.organizationId,
    required this.name,
    required this.slug,
    required this.plan,
    required this.isActive,
    required this.role,
  });

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        organizationId: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        plan: json['plan'] as String,
        isActive: json['is_active'] as bool? ?? true,
        role: MemberRole.parse(json['role'] as String),
      );

  final String organizationId;
  final String name;
  final String slug;
  final String plan;
  final bool isActive;
  final MemberRole role;
}

/// Who is signed in (`GET /auth/me`).
class AuthSession {
  const AuthSession({required this.user, required this.memberships});

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        user: AppUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
        memberships: (json['organizations'] as List)
            .map((m) => Membership.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList(),
      );

  final AppUser user;
  final List<Membership> memberships;
}
