import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/project_scope_provider.dart';
import '../application/workspace_controller.dart';
import '../domain/project_scope.dart';

/// Shows [builder] once a project is selected; otherwise the right state for why not
/// (loading, error, no organization, no project). Used by tabs that show one project's data.
class ProjectGate extends ConsumerWidget {
  const ProjectGate({super.key, required this.builder});

  final Widget Function(BuildContext context, ProjectScope scope) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workspace = ref.watch(workspaceControllerProvider);
    final scope = ref.watch(projectScopeProvider);
    if (scope != null) return builder(context, scope);

    return workspace.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.loadFailedTitle,
        body: errorMessage(l10n, error),
        action: OutlinedButton(
          onPressed: ref.read(workspaceControllerProvider.notifier).reload,
          child: Text(l10n.retry),
        ),
      ),
      data: (data) => data == null
          ? EmptyState(icon: Icons.apartment, title: l10n.noOrganizationsTitle, body: l10n.noOrganizationsBody)
          : EmptyState(icon: Icons.phone_iphone, title: l10n.noProjectsTitle, body: l10n.noProjectsBody),
    );
  }
}
