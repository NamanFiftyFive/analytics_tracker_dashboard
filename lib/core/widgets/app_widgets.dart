import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../network/api_exception.dart';
import '../theme/app_colors.dart';

/// The square chart mark from the design.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: const Color(0xFF0E6B70), borderRadius: BorderRadius.circular(size / 4)),
        child: Icon(Icons.show_chart_rounded, color: Colors.white, size: size * 0.7),
      );
}

/// Label above the input, as in the design.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
    this.fieldKey,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          TextFormField(
            key: fieldKey,
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: obscureText,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            onFieldSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      );
}

/// Red message box for a failed request.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(Icons.error_outline, color: scheme.error, size: 20),
            Expanded(child: Text(message, style: TextStyle(color: scheme.onErrorContainer, fontSize: 14))),
          ],
        ),
      ),
    );
  }
}

/// Icon, title, text and an optional action: for empty and "coming soon" screens.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.action});

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: colors.accentSoft, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            ),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(body, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5, color: colors.muted)),
            ?action,
          ],
        ),
      ),
    );
  }
}

/// A user-facing message for any error thrown by the data layer.
String errorMessage(AppLocalizations l10n, Object error) {
  if (error is ApiException) {
    if (error.kind == ApiErrorKind.network) return l10n.errorNetwork;
    if (error.message != null && error.message!.isNotEmpty) return error.message!;
  }
  return l10n.errorUnexpected;
}
