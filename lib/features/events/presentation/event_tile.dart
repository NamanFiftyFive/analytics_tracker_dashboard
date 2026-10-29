import 'package:flutter/material.dart';

import '../../../core/format/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../explorer/domain/explorer_models.dart';

const monoStyle = TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w500);

/// One event row: name and time, then who · where · device, then up to 2 properties.
class EventTile extends StatelessWidget {
  const EventTile({super.key, required this.event, this.onTap, this.showUser = true});

  final EventItem event;
  final VoidCallback? onTap;
  final bool showUser;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final format = Formatters.of(context);
    final details = [
      if (showUser) event.distinctId,
      ?event.location,
      ?(event.os ?? event.browser),
    ].join(' · ');
    final props = event.visibleProperties.entries.take(2).map((e) => '${e.key}: ${e.value}').join(' · ');

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.line))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                children: [
                  Expanded(child: Text(event.eventName, style: monoStyle, overflow: TextOverflow.ellipsis)),
                  Text(format.time(event.occurredAt), style: TextStyle(fontSize: 13, color: colors.muted)),
                ],
              ),
              if (details.isNotEmpty)
                Text(details, style: TextStyle(fontSize: 13, color: colors.muted), overflow: TextOverflow.ellipsis),
              if (props.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: colors.fill, borderRadius: BorderRadius.circular(6)),
                  child: Text(props,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
