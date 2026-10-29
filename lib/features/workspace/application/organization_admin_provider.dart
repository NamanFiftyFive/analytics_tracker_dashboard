import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_models.dart';
import 'workspace_controller.dart';

/// True when the signed-in user may manage the current organization: its admins, and super
/// admins (who act as admin everywhere). The backend enforces the same rule; this only
/// decides what the app offers.
final isOrganizationAdminProvider = Provider<bool>((ref) {
  final session = ref.watch(authControllerProvider).value;
  final organization = ref.watch(workspaceControllerProvider).value?.organization;
  return (session?.user.isSuperadmin ?? false) || organization?.role == MemberRole.admin;
});
