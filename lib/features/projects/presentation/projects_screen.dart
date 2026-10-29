import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../workspace/application/workspace_controller.dart';
import '../../workspace/domain/workspace_models.dart';
import '../application/project_providers.dart';
import '../domain/project_models.dart';
import 'new_project_sheet.dart';
import 'platform_labels.dart';

/// Every project of the current organization; admins can add one.
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final workspace = ref.watch(workspaceControllerProvider);
    final canManage = ref.watch(canManageProjectsProvider);
    final controller = ref.read(workspaceControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectsTitle), centerTitle: false),
      floatingActionButton: canManage && workspace.value != null
          ? FloatingActionButton.extended(
              key: const Key('new-project'),
              onPressed: () => showNewProjectSheet(context, workspace.value!.organization.organizationId),
              icon: const Icon(Icons.add),
              label: Text(l10n.newProjectButton),
            )
          : null,
      body: workspace.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.cloud_off,
          title: l10n.loadFailedTitle,
          body: errorMessage(l10n, error),
          action: OutlinedButton(onPressed: controller.reload, child: Text(l10n.retry)),
        ),
        data: (data) {
          if (data == null) {
            return EmptyState(icon: Icons.apartment, title: l10n.noOrganizationsTitle, body: l10n.noOrganizationsBody);
          }
          return RefreshIndicator(
            onRefresh: controller.reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: Text(l10n.projectsSubtitle, style: TextStyle(color: colors.muted, height: 1.4)),
                ),
                if (data.projects.isEmpty)
                  EmptyState(icon: Icons.phone_iphone, title: l10n.noProjectsTitle, body: l10n.noProjectsBody),
                for (final project in data.projects)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProjectCard(
                      project: project,
                      onTap: () => context.push(Routes.projectDetail(project.id)),
                    ),
                  ),
                if (!canManage)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(l10n.onlyAdminsCreateProjects, style: TextStyle(fontSize: 13, color: colors.muted)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final platform = ProjectPlatform.parse(project.platform);
    final noKey = project.activeApiKeys == 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: colors.accentSoft, borderRadius: BorderRadius.circular(12)),
                child: Icon(platformIcon(platform), color: Theme.of(context).colorScheme.primary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(project.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('${platformLabel(l10n, platform)} · ${project.timezone}',
                        style: TextStyle(fontSize: 13, color: colors.muted)),
                    Text(
                      l10n.activeKeysCount(project.activeApiKeys),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: noKey ? colors.warning : colors.success,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
