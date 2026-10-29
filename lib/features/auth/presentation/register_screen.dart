import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/auth_controller.dart';
import 'validators.dart';

/// Creates a new organization; the person registering becomes its admin.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organization = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_organization, _name, _email, _password]) {
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
      await ref.read(authControllerProvider.notifier).register(
            organizationName: _organization.text.trim(),
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: l10n.backToSignIn,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(Routes.signIn),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 18,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(l10n.registerTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                      Text(l10n.registerSubtitle, style: TextStyle(fontSize: 14, height: 1.5, color: colors.muted)),
                    ],
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                  LabeledTextField(
                    fieldKey: const Key('register-organization'),
                    label: l10n.organizationNameLabel,
                    hint: l10n.organizationNameHint,
                    controller: _organization,
                    autofillHints: const [AutofillHints.organizationName],
                    validator: (v) => validators.minLength(v, 2),
                  ),
                  LabeledTextField(
                    fieldKey: const Key('register-name'),
                    label: l10n.fullNameLabel,
                    hint: l10n.fullNameHint,
                    controller: _name,
                    autofillHints: const [AutofillHints.name],
                    validator: (v) => validators.minLength(v, 2),
                  ),
                  LabeledTextField(
                    fieldKey: const Key('register-email'),
                    label: l10n.workEmailLabel,
                    hint: l10n.emailHint,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: validators.email,
                  ),
                  LabeledTextField(
                    fieldKey: const Key('register-password'),
                    label: l10n.passwordLabel,
                    hint: l10n.passwordHint,
                    controller: _password,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: validators.newPassword,
                    onSubmitted: (_) => _submit(),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: colors.accentSoft, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(l10n.nextStepsTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        Text(l10n.nextStepsBody, style: const TextStyle(fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                  FilledButton(
                    key: const Key('register-submit'),
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : Text(l10n.createOrganizationButton),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l10n.haveAccountPrompt, style: TextStyle(color: colors.muted)),
                      TextButton(onPressed: () => context.go(Routes.signIn), child: Text(l10n.signInLink)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
