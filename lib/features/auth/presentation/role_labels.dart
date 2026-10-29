import '../../../l10n/generated/app_localizations.dart';
import '../domain/auth_models.dart';

String roleName(AppLocalizations l10n, MemberRole role) => switch (role) {
      MemberRole.admin => l10n.roleAdmin,
      MemberRole.analyst => l10n.roleAnalyst,
      MemberRole.viewer => l10n.roleViewer,
    };
