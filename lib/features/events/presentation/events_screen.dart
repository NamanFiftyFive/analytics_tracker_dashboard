import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../explorer/application/explorer_providers.dart';
import '../../explorer/domain/explorer_models.dart';
import '../../workspace/domain/project_scope.dart';
import '../../workspace/presentation/project_gate.dart';
import '../../workspace/presentation/project_switcher.dart';
import 'event_tile.dart';

/// Live feed of the selected project's events: search, filter by name, grouped by day.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: ProjectSwitcherTitle(title: l10n.tabEvents), centerTitle: false, toolbarHeight: 84),
      body: ProjectGate(builder: (context, scope) => _EventsView(key: ValueKey(scope), scope: scope)),
    );
  }
}

class _EventsView extends ConsumerStatefulWidget {
  const _EventsView({super.key, required this.scope});

  final ProjectScope scope;

  @override
  ConsumerState<_EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends ConsumerState<_EventsView> {
  static const _searchDelay = Duration(milliseconds: 400);

  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _eventName;
  String _search = '';

  EventFeedQuery get _query => EventFeedQuery(widget.scope, eventName: _eventName, search: _search);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Search after the user stops typing, not on every key press.
  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      if (mounted) setState(() => _search = text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final definitions = ref.watch(eventDefinitionsProvider(widget.scope)).value ?? const [];

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            spacing: 10,
            children: [
              TextField(
                key: const Key('events-search'),
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.searchEventsHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colors.fill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  key: const Key('event-chips'),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: l10n.allEventsFilter,
                      selected: _eventName == null,
                      onSelected: () => setState(() => _eventName = null),
                    ),
                    for (final definition in definitions)
                      _FilterChip(
                        label: definition.eventName,
                        mono: true,
                        selected: _eventName == definition.eventName,
                        onSelected: () => setState(() => _eventName = definition.eventName),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _EventFeed(query: _query)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected, this.mono = false});

  final String label;
  final bool selected;
  final bool mono;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label, style: mono ? const TextStyle(fontFamily: 'monospace', fontSize: 12) : null),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => onSelected(),
        ),
      );
}

class _EventFeed extends ConsumerWidget {
  const _EventFeed({required this.query});

  final EventFeedQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final feed = ref.watch(eventFeedProvider(query));

    Future<void> refresh() async {
      ref.invalidate(eventFeedProvider(query));
      ref.invalidate(eventDefinitionsProvider(query.scope));
      await ref.read(eventFeedProvider(query).future).catchError((_) => const PagedState<EventItem>(items: [], hasMore: false));
    }

    return feed.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.loadFailedTitle,
        body: errorMessage(l10n, error),
        action: OutlinedButton(onPressed: refresh, child: Text(l10n.retry)),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          final filtered = query.eventName != null || query.search.isNotEmpty;
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              children: [
                const SizedBox(height: 48),
                EmptyState(
                  icon: Icons.list_alt,
                  title: filtered ? l10n.noMatchingEventsTitle : l10n.noEventsYetTitle,
                  body: filtered ? l10n.noMatchingEventsBody : l10n.noEventsYetBody,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: _GroupedEventList(
            state: state,
            onLoadMore: () => ref.read(eventFeedProvider(query).notifier).loadMore(),
          ),
        );
      },
    );
  }
}

/// Events with a "Today / Yesterday / date" header before each new day; asks for more near the end.
class _GroupedEventList extends StatelessWidget {
  const _GroupedEventList({required this.state, required this.onLoadMore});

  final PagedState<EventItem> state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = Formatters.of(context);
    final colors = context.colors;

    final rows = <Object>[]; // String = day header, EventItem = event
    String? lastHeader;
    for (final event in state.items) {
      final header = format.dayHeader(event.occurredAt);
      if (header != lastHeader) rows.add(header);
      lastHeader = header;
      rows.add(event);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400) onLoadMore();
        return false;
      },
      child: ListView.builder(
        key: const Key('events-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: rows.length + 1,
        itemBuilder: (context, index) {
          if (index == rows.length) {
            if (state.loadingMore) {
              return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
            }
            if (state.loadMoreFailed) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l10n.loadMoreFailed, textAlign: TextAlign.center, style: TextStyle(color: colors.muted)),
              );
            }
            return const SizedBox(height: 24);
          }
          final row = rows[index];
          if (row is String) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Text(row.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: colors.muted)),
            );
          }
          final event = row as EventItem;
          return EventTile(
            key: ValueKey(event.id),
            event: event,
            onTap: event.personId == null ? null : () => context.push(Routes.eventUser(event.personId!)),
          );
        },
      ),
    );
  }
}
