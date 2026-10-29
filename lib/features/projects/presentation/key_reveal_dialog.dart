import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Shows a newly created API key: the only time the full key can be seen.
Future<void> showKeyRevealDialog(BuildContext context, String key) => showDialog<void>(
      context: context,
      barrierDismissible: false, // make people press Done after reading "shown only once"
      builder: (_) => _KeyRevealDialog(apiKey: key),
    );

class _KeyRevealDialog extends StatelessWidget {
  const _KeyRevealDialog({required this.apiKey});

  final String apiKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AlertDialog(
      title: Text(l10n.keyCreatedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(l10n.keyCreatedBody, style: TextStyle(color: colors.muted, height: 1.4)),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colors.fill, borderRadius: BorderRadius.circular(10)),
            child: SelectableText(
              apiKey,
              key: const Key('revealed-key'),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          key: const Key('copy-key'),
          icon: const Icon(Icons.copy, size: 18),
          label: Text(l10n.copyButton),
          onPressed: () => copyToClipboard(context, apiKey),
        ),
        FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.doneButton)),
      ],
    );
  }
}

Future<void> copyToClipboard(BuildContext context, String text) async {
  final messenger = ScaffoldMessenger.of(context);
  final copied = AppLocalizations.of(context).copiedMessage;
  await Clipboard.setData(ClipboardData(text: text));
  messenger.showSnackBar(SnackBar(content: Text(copied), duration: const Duration(seconds: 2)));
}
