import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/settings/settings_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/presentation/role_labels.dart';
import '../../workspace/application/workspace_controller.dart';

/// Language choices; null code = follow the phone.
enum LanguageChoice {
  system(null),
  english('en'),
  hindi('hi');

  const LanguageChoice(this.code);

  final String? code;

  static LanguageChoice from(Locale? locale) =>
      LanguageChoice.values.firstWhere((c) => c.code == locale?.languageCode, orElse: () => LanguageChoice.system);
}

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(authControllerProvider).value;
    final workspace = ref.watch(workspaceControllerProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final language = LanguageChoice.from(ref.watch(localeProvider));

    if (session == null) return const SizedBox.shrink();
    final organization = workspace?.organization;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: colors.hero,
                foregroundColor: colors.onHero,
                child: Text(session.user.displayName.characters.first.toUpperCase()),
              ),
              title: Text(session.user.email, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                organization != null
                    ? l10n.roleInOrganization(roleName(l10n, organization.role), organization.name)
                    : (session.user.isSuperadmin ? l10n.superAdminBadge : ''),
              ),
              trailing: session.user.isSuperadmin
                  ? Chip(
                      label: Text(l10n.superAdminBadge),
                      backgroundColor: colors.warningSoft,
                      labelStyle: TextStyle(color: colors.warning, fontWeight: FontWeight.w700, fontSize: 12),
                      side: BorderSide.none,
                    )
                  : null,
            ),
          ),
          if (session.memberships.length > 1 && organization != null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text(l10n.organizationLabel, style: TextStyle(fontSize: 12, color: colors.muted)),
                subtitle: Text(organization.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                trailing: Text(l10n.switchOrganization,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                onTap: () => _pickOrganization(context, ref, session, organization.organizationId),
              ),
            ),
          ],
          if (workspace != null) ...[
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('more-projects'),
                minTileHeight: 60,
                leading: Icon(Icons.dashboard_customize_outlined, color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.projectsMenuTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(l10n.projectsCount(workspace.projects.length)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.projects),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('more-members'),
                minTileHeight: 60,
                leading: Icon(Icons.group_outlined, color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.membersMenuTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(roleName(l10n, workspace.organization.role)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.members),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _SectionTitle(l10n.appearanceTitle),
          SegmentedButton<ThemeMode>(
            key: const Key('theme-selector'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem), icon: const Icon(Icons.brightness_auto)),
              ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight), icon: const Icon(Icons.light_mode)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark), icon: const Icon(Icons.dark_mode)),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) => ref.read(themeModeProvider.notifier).set(selection.first),
          ),
          const SizedBox(height: 20),
          _SectionTitle(l10n.languageTitle),
          SegmentedButton<LanguageChoice>(
            key: const Key('language-selector'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: LanguageChoice.system, label: Text(l10n.languageSystem)),
              ButtonSegment(value: LanguageChoice.english, label: Text(l10n.languageEnglish)),
              ButtonSegment(value: LanguageChoice.hindi, label: Text(l10n.languageHindi)),
            ],
            selected: {language},
            onSelectionChanged: (selection) {
              final code = selection.first.code;
              ref.read(localeProvider.notifier).set(code == null ? null : Locale(code));
            },
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            key: const Key('sign-out'),
            onPressed: () => _confirmSignOut(context, ref),
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            label: Text(l10n.signOutButton, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickOrganization(BuildContext context, WidgetRef ref, AuthSession session, String currentId) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(l10n.selectOrganizationTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            for (final membership in session.memberships)
              ListTile(
                title: Text(membership.name),
                subtitle: Text(roleName(l10n, membership.role)),
                trailing: membership.organizationId == currentId ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(sheetContext, membership.organizationId),
              ),
          ],
        ),
      ),
    );
    if (picked != null) ref.read(workspaceControllerProvider.notifier).selectOrganization(picked);
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          FilledButton(
            key: const Key('confirm-sign-out'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.signOutButton),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await ref.read(authControllerProvider.notifier).signOut();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: context.colors.muted),
        ),
      );
}
