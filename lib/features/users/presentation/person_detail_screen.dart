import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../events/presentation/event_tile.dart';
import '../../explorer/application/explorer_providers.dart';
import '../../explorer/domain/explorer_models.dart';
import '../../workspace/presentation/project_gate.dart';
import 'person_avatar.dart';

/// One user: who they are, totals, and their recent sessions as step-by-step timelines.
class PersonDetailScreen extends StatelessWidget {
  const PersonDetailScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.userTitle), centerTitle: false),
      body: ProjectGate(
        builder: (context, scope) => _PersonDetailView(query: PersonDetailQuery(scope, personId)),
      ),
    );
  }
}

class _PersonDetailView extends ConsumerWidget {
  const _PersonDetailView({required this.query});

  final PersonDetailQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(personDetailProvider(query));

    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.person_off,
        title: error is ApiException && error.statusCode == 404 ? l10n.userNotFound : l10n.loadFailedTitle,
        body: errorMessage(l10n, error),
        action: OutlinedButton(onPressed: () => ref.invalidate(personDetailProvider(query)), child: Text(l10n.retry)),
      ),
      data: (data) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(personDetailProvider(query));
          await ref.read(personDetailProvider(query).future).catchError((_) => data);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _ProfileHeader(detail: data),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(l10n.recentSessionsTitle.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: context.colors.muted)),
            ),
            if (data.sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(l10n.noSessions, style: TextStyle(color: context.colors.muted)),
              ),
            for (final session in data.sessions) _SessionCard(session: session),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = Formatters.of(context);
    final colors = context.colors;
    final person = detail.person;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            spacing: 14,
            children: [
              PersonAvatar(person: person, size: 52),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(person.distinctId,
                        key: const Key('person-distinct-id'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                    Text(
                      '${l10n.lastSeenLabel}: ${format.relative(person.lastSeenAt)}',
                      style: TextStyle(fontSize: 13, color: colors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (person.traits.isNotEmpty || person.lastOs != null)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final trait in person.traits.entries) _Chip('${trait.key}: ${trait.value}'),
                if (person.lastOs != null) _Chip(person.lastOs!),
              ],
            ),
          Row(
            spacing: 8,
            children: [
              _Stat(label: l10n.sessionsLabel, value: format.number(detail.sessionCount)),
              _Stat(label: l10n.eventsLabel, value: format.number(detail.eventCount)),
              _Stat(label: l10n.firstSeenLabel, value: format.shortDate(person.firstSeenAt)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: context.colors.fill, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text(label, style: TextStyle(fontSize: 12, color: context.colors.muted)),
            ],
          ),
        ),
      );
}

/// A session as a vertical timeline, newest step first.
class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final SessionWithEvents session;

  @override
  Widget build(BuildContext context) {
    final format = Formatters.of(context);
    final colors = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final end = session.endedAt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${format.dateTime(session.startedAt)}${end != null ? ' – ${format.time(end)}' : ''}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(format.duration(session.durationSeconds), style: TextStyle(fontSize: 13, color: colors.muted)),
                ],
              ),
              Column(
                children: [
                  for (var i = 0; i < session.events.length; i++)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          SizedBox(
                            width: 12,
                            child: Column(
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == 0 ? accent : null,
                                    border: Border.all(color: accent, width: 2),
                                  ),
                                ),
                                if (i < session.events.length - 1)
                                  Expanded(child: Container(width: 2, color: colors.line)),
                              ],
                            ),
                          ),
                          Expanded(child: _TimelineStep(event: session.events[i])),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final format = Formatters.of(context);
    final colors = context.colors;
    final props = event.visibleProperties.entries.take(2).map((e) => '${e.key}: ${e.value}');
    final details = [?event.location, ...props].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          Row(
            children: [
              Expanded(child: Text(event.eventName, style: monoStyle, overflow: TextOverflow.ellipsis)),
              Text(format.time(event.occurredAt), style: TextStyle(fontSize: 13, color: colors.muted)),
            ],
          ),
          if (details.isNotEmpty) Text(details, style: TextStyle(fontSize: 13, color: colors.muted)),
        ],
      ),
    );
  }
}
