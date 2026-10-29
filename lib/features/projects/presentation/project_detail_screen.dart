import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../workspace/application/workspace_controller.dart';
import '../../workspace/domain/project_scope.dart';
import '../../workspace/domain/workspace_models.dart';
import '../application/project_providers.dart';
import '../domain/project_models.dart';
import 'key_reveal_dialog.dart';
import 'platform_labels.dart';

/// One project: details, API keys (admins) and how to add the SDK.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workspace = ref.watch(workspaceControllerProvider).value;
    final project = workspace?.projects.where((p) => p.id == projectId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(project?.name ?? l10n.projectsTitle), centerTitle: false),
      body: workspace == null || project == null
          ? EmptyState(icon: Icons.phone_iphone, title: l10n.noProjectsTitle, body: l10n.noProjectsBody)
          : _ProjectDetail(
              project: project,
              scope: ProjectScope(organizationId: workspace.organization.organizationId, projectId: project.id),
            ),
    );
  }
}

class _ProjectDetail extends ConsumerWidget {
  const _ProjectDetail({required this.project, required this.scope});

  final Project project;
  final ProjectScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final canManage = ref.watch(canManageProjectsProvider);
    final platform = ProjectPlatform.parse(project.platform);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              children: [
                _Row(label: l10n.platformLabel, value: platformLabel(l10n, platform)),
                _Row(label: l10n.timezoneLabel, value: project.timezone),
                _Row(label: l10n.activeKeysLabel, value: '${project.activeApiKeys}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (canManage)
          _ApiKeysSection(scope: scope)
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: colors.fill, borderRadius: BorderRadius.circular(12)),
            child: Text(l10n.keysAdminOnly, key: const Key('keys-admin-only'), style: TextStyle(color: colors.muted)),
          ),
        const SizedBox(height: 16),
        _SdkSetupCard(),
      ],
    );
  }
}

class _ApiKeysSection extends ConsumerWidget {
  const _ApiKeysSection({required this.scope});

  final ProjectScope scope;

  Future<void> _newKey(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<String>(context: context, builder: (_) => const _KeyNameDialog());
    if (name == null || !context.mounted) return;
    try {
      final created = await ref.read(apiKeysProvider(scope).notifier).create(name);
      if (context.mounted) await showKeyRevealDialog(context, created.key);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
      }
    }
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref, ApiKey key) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.revokeKeyTitle),
        content: Text(l10n.revokeKeyBody(key.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          FilledButton(
            key: const Key('confirm-revoke'),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.revokeKeyButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(apiKeysProvider(scope).notifier).revoke(key.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = Formatters.of(context);
    final keys = ref.watch(apiKeysProvider(scope));

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(child: Text(l10n.apiKeysTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                TextButton.icon(
                  key: const Key('new-key'),
                  onPressed: () => _newKey(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.newKeyButton),
                ),
              ],
            ),
          ),
          const Divider(),
          keys.when(
            skipLoadingOnReload: true,
            loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 8,
                children: [
                  Text(errorMessage(l10n, error)),
                  OutlinedButton(onPressed: () => ref.invalidate(apiKeysProvider(scope)), child: Text(l10n.retry)),
                ],
              ),
            ),
            data: (list) => list.isEmpty
                ? Padding(padding: const EdgeInsets.all(16), child: Text(l10n.noKeysYet, style: TextStyle(color: colors.muted)))
                : Column(
                    children: [
                      for (final key in list)
                        ListTile(
                          key: Key('key-${key.id}'),
                          title: Text(key.name, style: TextStyle(fontWeight: FontWeight.w600, color: key.isActive ? null : colors.muted)),
                          subtitle: Text(
                            '${key.keyPrefix}… · ${key.lastUsedAt == null ? l10n.keyNeverUsed : l10n.keyUsed(format.relative(key.lastUsedAt!))}',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          trailing: key.isActive
                              ? TextButton(
                                  key: Key('revoke-${key.id}'),
                                  onPressed: () => _revoke(context, ref, key),
                                  child: Text(l10n.revokeKeyButton,
                                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                )
                              : _Badge(text: l10n.keyRevoked, color: colors.muted, background: colors.fill),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _KeyNameDialog extends StatefulWidget {
  const _KeyNameDialog();

  @override
  State<_KeyNameDialog> createState() => _KeyNameDialogState();
}

class _KeyNameDialogState extends State<_KeyNameDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.newKeyButton),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('key-name'),
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.keyNameLabel, hintText: l10n.keyNameHint),
          validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(key: const Key('create-key'), onPressed: _submit, child: Text(l10n.createKeyButton)),
      ],
    );
  }
}

/// Copy-paste setup for the Flutter SDK, pointing at this app's backend.
class _SdkSetupCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final host = ref.watch(appConfigProvider).apiBaseUrl.replaceFirst(RegExp(r'/api/v1$'), '');
    const dependency = 'event_tracker_analytics:\n  path: ../event_tracker_analytics';
    final init = "await EventTracker.init(const TrackerConfig(\n  apiKey: 'pk_live_…',\n  host: '$host',\n));";

    Widget code(String text, String copyKey) => Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
          decoration: BoxDecoration(color: colors.fill, borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5)),
                ),
              ),
              IconButton(
                key: Key(copyKey),
                tooltip: l10n.copyButton,
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => copyToClipboard(context, text),
              ),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(l10n.sdkSetupTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text(l10n.sdkStepDependency, style: TextStyle(fontSize: 13, color: colors.muted)),
            code(dependency, 'copy-dependency'),
            Text(l10n.sdkStepInit, style: TextStyle(fontSize: 13, color: colors.muted)),
            code(init, 'copy-init'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: context.colors.muted))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color, required this.background});

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      );
}
