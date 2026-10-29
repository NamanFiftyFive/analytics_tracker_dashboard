import '../../auth/domain/auth_models.dart';

/// Someone in the organization (`GET /orgs/{id}/members`).
class Member {
  const Member({
    required this.userId,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.fullName,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        userId: json['user_id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String?,
        role: MemberRole.parse(json['role'] as String),
        joinedAt: DateTime.parse(json['joined_at'] as String).toLocal(),
      );

  final String userId;
  final String email;
  final String? fullName;
  final MemberRole role;
  final DateTime joinedAt;

  String get displayName => (fullName?.trim().isNotEmpty ?? false) ? fullName!.trim() : email;
}
