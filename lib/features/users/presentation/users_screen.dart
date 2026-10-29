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
import 'person_avatar.dart';

/// Everyone who used the selected project's app, most recently active first.
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: ProjectSwitcherTitle(title: l10n.tabUsers), centerTitle: false, toolbarHeight: 84),
      body: ProjectGate(builder: (context, scope) => _UsersView(key: ValueKey(scope), scope: scope)),
    );
  }
}

class _UsersView extends ConsumerStatefulWidget {
  const _UsersView({super.key, required this.scope});

  final ProjectScope scope;

  @override
  ConsumerState<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends ConsumerState<_UsersView> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  PersonFilter _filter = PersonFilter.all;
  String _search = '';
  PersonCounts? _counts; // kept while another filter loads, so the tab labels don't flicker

  PersonListQuery get _query => PersonListQuery(widget.scope, filter: _filter, search: _search);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _search = text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final list = ref.watch(personListProvider(_query));
    _counts = list.value?.counts ?? _counts;
    final counts = _counts;

    Future<void> refresh() async {
      ref.invalidate(personListProvider(_query));
      await ref.read(personListProvider(_query).future).catchError(
            (_) => const PersonListState(items: [], hasMore: false, counts: PersonCounts(all: 0, identified: 0, newUsers: 0)),
          );
    }

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              TextField(
                key: const Key('users-search'),
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.searchUsersHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colors.fill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              Semantics(
                label: l10n.usersFilterLabel,
                child: SegmentedButton<PersonFilter>(
                  key: const Key('users-filter'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: PersonFilter.all, label: Text(l10n.filterAll(counts?.all ?? 0))),
                    ButtonSegment(value: PersonFilter.identified, label: Text(l10n.filterKnown(counts?.identified ?? 0))),
                    ButtonSegment(value: PersonFilter.newUsers, label: Text(l10n.filterNew(counts?.newUsers ?? 0))),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (selection) => setState(() => _filter = selection.first),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.when(
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
                final filtered = _filter != PersonFilter.all || _search.isNotEmpty;
                return RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView(
                    children: [
                      const SizedBox(height: 48),
                      EmptyState(
                        icon: Icons.group,
                        title: filtered ? l10n.noMatchingUsersTitle : l10n.noUsersTitle,
                        body: filtered ? l10n.noMatchingEventsBody : l10n.noUsersBody,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: refresh,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.extentAfter < 400) ref.read(personListProvider(_query).notifier).loadMore();
                    return false;
                  },
                  child: ListView.builder(
                    key: const Key('users-list'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
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
                      final person = state.items[index];
                      return _PersonTile(
                        key: ValueKey(person.id),
                        person: person,
                        onTap: () => context.push(Routes.userDetail(person.id)),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({super.key, required this.person, required this.onTap});

  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = Formatters.of(context);
    final colors = context.colors;
    final details = person.isIdentified
        ? [...person.traits.values.take(2).map((v) => '$v'), ?person.lastOs]
        : [l10n.anonymousUser, ?person.lastOs];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.line))),
          child: Row(
            spacing: 12,
            children: [
              PersonAvatar(person: person),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      person.distinctId,
                      style: person.isIdentified
                          ? const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)
                          : const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(details.join(' · '),
                        style: TextStyle(fontSize: 13, color: colors.muted), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 3,
                children: [
                  Text(l10n.eventsCount(person.eventCount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(format.relative(person.lastSeenAt), style: TextStyle(fontSize: 12, color: colors.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
