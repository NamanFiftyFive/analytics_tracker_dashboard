import '../../../l10n/generated/app_localizations.dart';

/// Form checks matching the backend's rules, so most mistakes are caught before a request.
class Validators {
  Validators(this._l10n);

  final AppLocalizations _l10n;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _l10n.validationRequired;
    if (!_emailPattern.hasMatch(text)) return _l10n.validationEmail;
    return null;
  }

  /// Sign-in only checks the field is filled; the server decides if it's right.
  String? requiredField(String? value) =>
      (value == null || value.isEmpty) ? _l10n.validationRequired : null;

  String? newPassword(String? value) {
    if (value == null || value.isEmpty) return _l10n.validationRequired;
    if (value.length < 8) return _l10n.validationPasswordLength;
    return null;
  }

  String? minLength(String? value, int min) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _l10n.validationRequired;
    if (text.length < min) return _l10n.validationMinLength(min);
    return null;
  }
}
