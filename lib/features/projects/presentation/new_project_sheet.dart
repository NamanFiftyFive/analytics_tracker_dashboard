import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/validators.dart';
import '../../workspace/application/workspace_controller.dart';
import '../data/projects_repository.dart';
import '../domain/project_models.dart';
import 'key_reveal_dialog.dart';
import 'platform_labels.dart';

/// Bottom sheet to create a project. On success it shows the first API key once.
Future<void> showNewProjectSheet(BuildContext context, String organizationId) async {
  final createdKey = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true, // lets the sheet move above the keyboard
    showDragHandle: true,
    builder: (_) => _NewProjectSheet(organizationId: organizationId),
  );
  if (createdKey != null && context.mounted) await showKeyRevealDialog(context, createdKey);
}

class _NewProjectSheet extends ConsumerStatefulWidget {
  const _NewProjectSheet({required this.organizationId});

  final String organizationId;

  @override
  ConsumerState<_NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends ConsumerState<_NewProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _timezone = TextEditingController(text: 'Asia/Kolkata');
  ProjectPlatform _platform = ProjectPlatform.flutter;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _timezone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final created = await ref.read(projectsRepositoryProvider).createProject(
            widget.organizationId,
            name: _name.text.trim(),
            platform: _platform,
            timezone: _timezone.text.trim(),
          );
      await ref.read(workspaceControllerProvider.notifier).reload();
      if (mounted) Navigator.pop(context, created.firstKey.key);
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validators = Validators(l10n);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(l10n.newProjectButton, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              if (_error != null) ErrorBanner(message: _error!),
              LabeledTextField(
                fieldKey: const Key('project-name'),
                label: l10n.projectNameLabel,
                hint: l10n.projectNameHint,
                controller: _name,
                validator: (v) => validators.minLength(v, 2),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(l10n.platformLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final platform in ProjectPlatform.values)
                        ChoiceChip(
                          key: Key('platform-${platform.apiValue}'),
                          label: Text(platformLabel(l10n, platform)),
                          selected: _platform == platform,
                          onSelected: (_) => setState(() => _platform = platform),
                        ),
                    ],
                  ),
                ],
              ),
              LabeledTextField(
                fieldKey: const Key('project-timezone'),
                label: l10n.timezoneLabel,
                hint: l10n.timezoneHint,
                controller: _timezone,
                textInputAction: TextInputAction.done,
                validator: validators.requiredField,
                onSubmitted: (_) => _submit(),
              ),
              Text(l10n.timezoneHelp, style: Theme.of(context).textTheme.bodySmall),
              FilledButton(
                key: const Key('create-project'),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text(l10n.createProjectButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
