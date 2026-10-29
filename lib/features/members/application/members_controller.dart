import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../data/members_repository.dart';
import '../domain/member_models.dart';

/// The members of one organization, with add / change role / remove.
/// Methods throw ApiException so the screen can show the server's reason
/// (e.g. "An organization must keep at least one admin").
class MembersController extends AsyncNotifier<List<Member>> {
  MembersController(this.organizationId);

  final String organizationId;

  MembersRepository get _repository => ref.read(membersRepositoryProvider);

  String? get _myUserId => ref.read(authControllerProvider).value?.user.id;

  @override
  Future<List<Member>> build() => _repository.list(organizationId);

  Future<Member> add({required String email, required MemberRole role, String? fullName, String? password}) async {
    final member = await _repository.add(
      organizationId,
      email: email,
      role: role,
      fullName: fullName,
      password: password,
    );
    await _reload();
    return member;
  }

  Future<void> changeRole(String userId, MemberRole role) async {
    await _repository.changeRole(organizationId, userId, role);
    await _reload();
    // My own role changed: reload my session so what I'm allowed to see updates now.
    if (userId == _myUserId) await ref.read(authControllerProvider.notifier).refreshSession();
  }

  /// Remove someone, or leave (when [userId] is me).
  Future<void> remove(String userId) async {
    await _repository.remove(organizationId, userId);
    if (userId == _myUserId) {
      // I left: my organizations changed; the workspace reloads from the new session.
      await ref.read(authControllerProvider.notifier).refreshSession();
      return;
    }
    await _reload();
  }

  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final membersProvider =
    AsyncNotifierProvider.autoDispose.family<MembersController, List<Member>, String>(MembersController.new);
