import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_widgets.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shown while the saved login is checked at app start.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.hero,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            const AppLogo(size: 56),
            Text(l10n.appTitle, style: TextStyle(color: colors.onHero, fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onHeroMuted, semanticsLabel: l10n.loading),
            ),
          ],
        ),
      ),
    );
  }
}
