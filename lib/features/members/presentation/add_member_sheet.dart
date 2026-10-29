import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/presentation/role_labels.dart';
import '../../auth/presentation/validators.dart';
import '../application/members_controller.dart';

/// Admin form: add a teammate. A new email gets an account with the temporary password.
Future<void> showAddMemberSheet(BuildContext context, String organizationId) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final added = await showModalBottomSheet<(String, MemberRole)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AddMemberSheet(organizationId: organizationId),
  );
  if (added != null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.memberAdded(added.$1, roleName(l10n, added.$2)))));
  }
}

class _AddMemberSheet extends ConsumerStatefulWidget {
  const _AddMemberSheet({required this.organizationId});

  final String organizationId;

  @override
  ConsumerState<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<_AddMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  MemberRole _role = MemberRole.viewer;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_email, _name, _password]) {
      c.dispose();
    }
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
      final member = await ref.read(membersProvider(widget.organizationId).notifier).add(
            email: _email.text.trim(),
            role: _role,
            fullName: _name.text.trim(),
            password: _password.text,
          );
      if (mounted) Navigator.pop(context, (member.email, member.role));
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
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
              Text(l10n.addMemberTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              if (_error != null) ErrorBanner(message: _error!),
              LabeledTextField(
                fieldKey: const Key('member-email'),
                label: l10n.emailLabel,
                hint: l10n.emailHint,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: validators.email,
              ),
              LabeledTextField(
                fieldKey: const Key('member-name'),
                label: l10n.fullNameOptionalLabel,
                hint: l10n.fullNameHint,
                controller: _name,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  Text(l10n.roleLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  SegmentedButton<MemberRole>(
                    key: const Key('member-role'),
                    showSelectedIcon: false,
                    segments: [
                      for (final role in [MemberRole.viewer, MemberRole.analyst, MemberRole.admin])
                        ButtonSegment(value: role, label: Text(roleName(l10n, role))),
                    ],
                    selected: {_role},
                    onSelectionChanged: (selection) => setState(() => _role = selection.first),
                  ),
                  Text(l10n.roleHelp, style: TextStyle(fontSize: 12, height: 1.4, color: colors.muted)),
                ],
              ),
              LabeledTextField(
                fieldKey: const Key('member-password'),
                label: l10n.temporaryPasswordLabel,
                hint: l10n.temporaryPasswordHint,
                controller: _password,
                textInputAction: TextInputAction.done,
                // Optional (existing accounts don't need one), but if given it must be valid.
                validator: (value) => (value == null || value.isEmpty) ? null : validators.newPassword(value),
                onSubmitted: (_) => _submit(),
              ),
              Text(l10n.addMemberHelp, style: TextStyle(fontSize: 12, height: 1.4, color: colors.muted)),
              FilledButton(
                key: const Key('submit-member'),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text(l10n.addMemberButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
