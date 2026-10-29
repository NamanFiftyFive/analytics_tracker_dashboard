import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../auth/domain/auth_models.dart';
import '../domain/member_models.dart';

class MembersRepository {
  MembersRepository(this._api);

  final ApiClient _api;

  static Member _member(Object? data) => Member.fromJson(Map<String, dynamic>.from(data as Map));

  Future<List<Member>> list(String organizationId) => _api.get(
        '/orgs/$organizationId/members',
        (data) => (data as List).map(_member).toList(),
      );

  /// Adds an existing account, or creates one when [password] is given and the email is new.
  Future<Member> add(
    String organizationId, {
    required String email,
    required MemberRole role,
    String? fullName,
    String? password,
  }) =>
      _api.post(
        '/orgs/$organizationId/members',
        _member,
        body: {
          'email': email,
          'role': role.name,
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
          if (password != null && password.isNotEmpty) 'password': password,
        },
      );

  Future<Member> changeRole(String organizationId, String userId, MemberRole role) =>
      _api.patch('/orgs/$organizationId/members/$userId', _member, body: {'role': role.name});

  Future<void> remove(String organizationId, String userId) =>
      _api.delete('/orgs/$organizationId/members/$userId', (_) {});
}

final membersRepositoryProvider = Provider<MembersRepository>(
  (ref) => MembersRepository(ref.watch(apiClientProvider)),
);
