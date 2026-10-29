import 'package:flutter/material.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Placeholder until the alerts API exists.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabAlerts), centerTitle: false),
      body: EmptyState(icon: Icons.notifications, title: l10n.comingSoonTitle, body: l10n.alertsComingSoon),
    );
  }
}
