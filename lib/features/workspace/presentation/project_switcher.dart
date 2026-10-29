import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/workspace_controller.dart';

/// Bottom sheet listing the organization's projects. Picking one changes the project for
/// every tab (Overview, Events, Users share the same selection).
Future<void> showProjectPicker(BuildContext context, WidgetRef ref) async {
  final workspace = ref.read(workspaceControllerProvider).value;
  if (workspace == null || workspace.projects.isEmpty) return;
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
            child: Text(l10n.selectProjectTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          for (final project in workspace.projects)
            ListTile(
              key: Key('pick-project-${project.id}'),
              title: Text(project.name),
              subtitle: Text(project.platform),
              trailing: project.id == workspace.selectedProject?.id ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(sheetContext, project.id),
            ),
        ],
      ),
    ),
  );
  if (picked != null) ref.read(workspaceControllerProvider.notifier).selectProject(picked);
}

/// AppBar title for project-specific tabs: the tab name, and below it the current project
/// ("Tracker Test App ▾"), tappable to switch when the organization has more than one.
class ProjectSwitcherTitle extends ConsumerWidget {
  const ProjectSwitcherTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final workspace = ref.watch(workspaceControllerProvider).value;
    final project = workspace?.selectedProject;
    final canSwitch = (workspace?.projects.length ?? 0) > 1;

    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(title),
        if (project != null)
          // A tinted chip so it's obvious which project's data the tab shows.
          Semantics(
            button: canSwitch,
            label: canSwitch ? l10n.switchProject : null,
            child: Material(
              color: colors.accentSoft,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                key: const Key('tab-project-switcher'),
                onTap: canSwitch ? () => showProjectPicker(context, ref) : null,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 8, 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      Icon(Icons.phone_iphone, size: 16, color: accent),
                      Flexible(
                        child: Text(
                          project.name,
                          key: const Key('tab-project-name'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accent),
                        ),
                      ),
                      if (canSwitch) Icon(Icons.expand_more, size: 18, color: accent),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
