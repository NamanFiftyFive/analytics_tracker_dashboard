import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/project_models.dart';

String platformLabel(AppLocalizations l10n, ProjectPlatform platform) => switch (platform) {
      ProjectPlatform.flutter => l10n.platformFlutter,
      ProjectPlatform.android => l10n.platformAndroid,
      ProjectPlatform.ios => l10n.platformIos,
      ProjectPlatform.web => l10n.platformWeb,
      ProjectPlatform.other => l10n.platformOther,
    };

IconData platformIcon(ProjectPlatform platform) => switch (platform) {
      ProjectPlatform.web => Icons.public,
      ProjectPlatform.other => Icons.apps,
      _ => Icons.phone_iphone,
    };
