import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/auth_controller.dart';
import 'validators.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      await ref.read(authControllerProvider.notifier).signIn(email: _email.text.trim(), password: _password.text);
      // The router moves to the dashboard when the signed-in state changes.
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: colors.hero,
              padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      const AppLogo(),
                      Text(l10n.appTitle, style: TextStyle(color: colors.onHero, fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text(
                    l10n.heroTitle,
                    style: TextStyle(color: colors.onHero, fontSize: 28, height: 1.2, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Text(l10n.signInTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                          Text(l10n.signInSubtitle, style: TextStyle(fontSize: 14, height: 1.5, color: colors.muted)),
                        ],
                      ),
                      if (_error != null) ErrorBanner(message: _error!),
                      LabeledTextField(
                        fieldKey: const Key('signin-email'),
                        label: l10n.emailLabel,
                        hint: l10n.emailHint,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: validators.email,
                      ),
                      LabeledTextField(
                        fieldKey: const Key('signin-password'),
                        label: l10n.passwordLabel,
                        hint: l10n.passwordHint,
                        controller: _password,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: validators.requiredField,
                        onSubmitted: (_) => _submit(),
                      ),
                      FilledButton(
                        key: const Key('signin-submit'),
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                            : Text(l10n.signInButton),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.noAccountPrompt, style: TextStyle(color: colors.muted)),
                          TextButton(
                            key: const Key('go-register'),
                            onPressed: () => context.go(Routes.register),
                            child: Text(l10n.createOrganizationLink),
                          ),
                        ],
                      ),
                      Text(
                        l10n.joinTeamNote,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, height: 1.5, color: colors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
