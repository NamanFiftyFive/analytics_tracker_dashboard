import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/presentation/role_labels.dart';
import '../../workspace/application/organization_admin_provider.dart';
import '../../workspace/application/workspace_controller.dart';
import '../application/members_controller.dart';
import '../domain/member_models.dart';
import 'add_member_sheet.dart';

/// The current organization's team. Admins add people, change roles and remove; anyone can leave.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final organization = ref.watch(workspaceControllerProvider).value?.organization;
    final isAdmin = ref.watch(isOrganizationAdminProvider);

    if (organization == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.membersTitle), centerTitle: false),
        body: EmptyState(icon: Icons.apartment, title: l10n.noOrganizationsTitle, body: l10n.noOrganizationsBody),
      );
    }
    final members = ref.watch(membersProvider(organization.organizationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.membersTitle), centerTitle: false),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              key: const Key('add-member'),
              onPressed: () => showAddMemberSheet(context, organization.organizationId),
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(l10n.addMemberButton),
            )
          : null,
      body: members.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.cloud_off,
          title: l10n.membersLoadFailed,
          body: errorMessage(l10n, error),
          action: OutlinedButton(
            onPressed: () => ref.invalidate(membersProvider(organization.organizationId)),
            child: Text(l10n.retry),
          ),
        ),
        data: (list) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(membersProvider(organization.organizationId));
            await ref.read(membersProvider(organization.organizationId).future).catchError((_) => list);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < list.length; i++) ...[
                      if (i > 0) const Divider(),
                      _MemberTile(
                        member: list[i],
                        organization: organization,
                        isAdmin: isAdmin,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
                child: Text(l10n.roleHelp, style: TextStyle(fontSize: 13, height: 1.4, color: colors.muted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MemberAction { remove, leave }

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.member, required this.organization, required this.isAdmin});

  final Member member;
  final Membership organization;
  final bool isAdmin;

  MembersController _controller(WidgetRef ref) => ref.read(membersProvider(organization.organizationId).notifier);

  /// Runs an action; on failure shows the server's reason (e.g. last admin) in a snackbar.
  Future<bool> _run(BuildContext context, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      return true;
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
      return false;
    }
  }

  Future<void> _changeRole(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final role = await showModalBottomSheet<MemberRole>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(l10n.changeRoleTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            for (final role in [MemberRole.viewer, MemberRole.analyst, MemberRole.admin])
              ListTile(
                key: Key('role-option-${role.name}'),
                title: Text(roleName(l10n, role)),
                trailing: role == member.role ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(sheetContext, role),
              ),
          ],
        ),
      ),
    );
    if (role == null || role == member.role || !context.mounted) return;
    final ok = await _run(context, () => _controller(ref).changeRole(member.userId, role));
    if (ok) messenger.showSnackBar(SnackBar(content: Text(l10n.roleChanged(roleName(l10n, role)))));
  }

  Future<void> _confirmAndRemove(BuildContext context, WidgetRef ref, {required bool leaving}) async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(leaving ? l10n.leaveOrganizationTitle(organization.name) : l10n.removeMemberTitle(member.email)),
        content: Text(leaving ? l10n.leaveOrganizationBody : l10n.removeMemberBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          FilledButton(
            key: const Key('confirm-remove-member'),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(leaving ? l10n.leaveOrganizationButton : l10n.removeMemberButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await _run(context, () => _controller(ref).remove(member.userId));
    if (ok && leaving) router.go(Routes.overview); // this organization is no longer mine
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final isMe = ref.watch(authControllerProvider).value?.user.id == member.userId;
    final joined = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(member.joinedAt);
    final roleChip = _RoleChip(role: member.role, onTap: isAdmin ? () => _changeRole(context, ref) : null);
    final actions = [
      if (isMe) _MemberAction.leave,
      if (!isMe && isAdmin) _MemberAction.remove,
    ];

    return ListTile(
      key: Key('member-${member.userId}'),
      contentPadding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
      leading: CircleAvatar(
        backgroundColor: isMe ? colors.hero : colors.accentSoft,
        foregroundColor: isMe ? colors.onHero : Theme.of(context).colorScheme.primary,
        child: Text(member.displayName.characters.first.toUpperCase()),
      ),
      title: Row(
        spacing: 6,
        children: [
          Flexible(child: Text(member.displayName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
          if (isMe)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: colors.fill, borderRadius: BorderRadius.circular(6)),
              child: Text(l10n.youLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      subtitle: Text(
        [if (member.fullName?.isNotEmpty ?? false) member.email, l10n.joinedOn(joined)].join(' · '),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          roleChip,
          if (actions.isEmpty)
            const SizedBox(width: 12)
          else
            PopupMenuButton<_MemberAction>(
              key: Key('member-menu-${member.userId}'),
              tooltip: l10n.memberActions(member.email),
              onSelected: (action) => _confirmAndRemove(context, ref, leaving: action == _MemberAction.leave),
              itemBuilder: (_) => [
                for (final action in actions)
                  PopupMenuItem(
                    value: action,
                    child: Text(
                      action == _MemberAction.leave ? l10n.leaveOrganizationButton : l10n.removeMemberButton,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role, this.onTap});

  final MemberRole role;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final admin = role == MemberRole.admin;
    final foreground = admin ? colors.onHero : Theme.of(context).colorScheme.primary;
    return Material(
      color: admin ? colors.hero : colors.accentSoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: onTap == null ? null : const Key('role-chip'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 4, onTap == null ? 10 : 6, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(roleName(l10n, role), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: foreground)),
                if (onTap != null) Icon(Icons.expand_more, size: 16, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
