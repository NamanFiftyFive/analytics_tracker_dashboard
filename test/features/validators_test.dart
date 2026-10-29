import 'package:analytics_tracker/features/auth/presentation/validators.dart';
import 'package:analytics_tracker/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final v = Validators(AppLocalizationsEn());

  test('email', () {
    expect(v.email(''), 'This field is required');
    expect(v.email('not-an-email'), 'Enter a valid email address');
    expect(v.email('a@b'), 'Enter a valid email address');
    expect(v.email('  asha@acme.com  '), isNull, reason: 'surrounding spaces are ignored');
  });

  test('new password needs 8 characters', () {
    expect(v.newPassword(''), 'This field is required');
    expect(v.newPassword('short'), 'Use at least 8 characters');
    expect(v.newPassword('supersecret1'), isNull);
  });

  test('sign-in password only needs to be filled in', () {
    expect(v.requiredField(''), 'This field is required');
    expect(v.requiredField('x'), isNull);
  });

  test('minimum length', () {
    expect(v.minLength(' ', 2), 'This field is required');
    expect(v.minLength('A', 2), 'Use at least 2 characters');
    expect(v.minLength('Acme', 2), isNull);
  });
}
