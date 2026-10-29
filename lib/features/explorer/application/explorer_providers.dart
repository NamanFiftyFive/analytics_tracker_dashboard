import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workspace/domain/project_scope.dart';
import '../data/explorer_repository.dart';
import '../domain/explorer_models.dart';

// ── Event names (filter chips) ───────────────────────────────────────────────

final eventDefinitionsProvider = FutureProvider.autoDispose.family<List<EventDefinition>, ProjectScope>(
  (ref, scope) => ref.watch(explorerRepositoryProvider).eventDefinitions(scope),
);

// ── Paged lists ──────────────────────────────────────────────────────────────

/// A list that grows page by page (infinite scroll).
class PagedState<T> {
  const PagedState({required this.items, required this.hasMore, this.loadingMore = false, this.loadMoreFailed = false});

  final List<T> items;
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;

  PagedState<T> copyWith({List<T>? items, bool? hasMore, bool? loadingMore, bool? loadMoreFailed}) => PagedState(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
        loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      );
}

/// What the Events tab asks for: the project, an optional event name and search text.
class EventFeedQuery {
  const EventFeedQuery(this.scope, {this.eventName, this.search = ''});

  final ProjectScope scope;
  final String? eventName;
  final String search;

  @override
  bool operator ==(Object other) =>
      other is EventFeedQuery && other.scope == scope && other.eventName == eventName && other.search == search;

  @override
  int get hashCode => Object.hash(scope, eventName, search);
}

/// The event feed for one query. Newest first; [loadMore] fetches older events with the cursor.
class EventFeedController extends AsyncNotifier<PagedState<EventItem>> {
  EventFeedController(this.query);

  final EventFeedQuery query;
  String? _cursor;

  ExplorerRepository get _repository => ref.read(explorerRepositoryProvider);

  @override
  Future<PagedState<EventItem>> build() async {
    final page = await _repository.events(query.scope, eventName: query.eventName, search: query.search);
    _cursor = page.nextCursor;
    return PagedState(items: page.items, hasMore: page.nextCursor != null);
  }

  Future<void> loadMore() async {
    final current = state.value;
    // After a failure, wait for pull-to-refresh (which rebuilds the list) instead of retrying
    // on every scroll, which would hit a struggling server again and hide the error message.
    if (current == null || !current.hasMore || current.loadingMore || current.loadMoreFailed || _cursor == null) {
      return;
    }
    state = AsyncData(current.copyWith(loadingMore: true, loadMoreFailed: false));
    try {
      final page = await _repository.events(
        query.scope,
        eventName: query.eventName,
        search: query.search,
        cursor: _cursor,
      );
      _cursor = page.nextCursor;
      state = AsyncData(PagedState(items: [...current.items, ...page.items], hasMore: page.nextCursor != null));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false, loadMoreFailed: true));
    }
  }
}

final eventFeedProvider =
    AsyncNotifierProvider.autoDispose.family<EventFeedController, PagedState<EventItem>, EventFeedQuery>(
  EventFeedController.new,
);

/// What the Users tab asks for: the project, a filter and search text.
class PersonListQuery {
  const PersonListQuery(this.scope, {this.filter = PersonFilter.all, this.search = ''});

  final ProjectScope scope;
  final PersonFilter filter;
  final String search;

  @override
  bool operator ==(Object other) =>
      other is PersonListQuery && other.scope == scope && other.filter == filter && other.search == search;

  @override
  int get hashCode => Object.hash(scope, filter, search);
}

class PersonListState extends PagedState<Person> {
  const PersonListState({
    required super.items,
    required super.hasMore,
    required this.counts,
    super.loadingMore,
    super.loadMoreFailed,
  });

  /// Totals for the All / Known / New tabs.
  final PersonCounts counts;

  @override
  PersonListState copyWith({List<Person>? items, bool? hasMore, bool? loadingMore, bool? loadMoreFailed}) =>
      PersonListState(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        counts: counts,
        loadingMore: loadingMore ?? this.loadingMore,
        loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      );
}

/// The users list for one query, most recently active first; [loadMore] fetches the next page.
class PersonListController extends AsyncNotifier<PersonListState> {
  PersonListController(this.query);

  final PersonListQuery query;
  static const pageSize = 50;

  ExplorerRepository get _repository => ref.read(explorerRepositoryProvider);

  @override
  Future<PersonListState> build() async {
    final page = await _repository.persons(query.scope, filter: query.filter, search: query.search, limit: pageSize);
    return PersonListState(items: page.items, hasMore: page.items.length < page.total, counts: page.counts);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore || current.loadMoreFailed) return; // see EventFeedController
    state = AsyncData(current.copyWith(loadingMore: true, loadMoreFailed: false));
    try {
      final page = await _repository.persons(
        query.scope,
        filter: query.filter,
        search: query.search,
        limit: pageSize,
        offset: current.items.length,
      );
      final items = [...current.items, ...page.items];
      state = AsyncData(PersonListState(items: items, hasMore: items.length < page.total, counts: page.counts));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false, loadMoreFailed: true));
    }
  }
}

final personListProvider =
    AsyncNotifierProvider.autoDispose.family<PersonListController, PersonListState, PersonListQuery>(
  PersonListController.new,
);

// ── One user ─────────────────────────────────────────────────────────────────

class PersonDetailQuery {
  const PersonDetailQuery(this.scope, this.personId);

  final ProjectScope scope;
  final String personId;

  @override
  bool operator ==(Object other) => other is PersonDetailQuery && other.scope == scope && other.personId == personId;

  @override
  int get hashCode => Object.hash(scope, personId);
}

final personDetailProvider = FutureProvider.autoDispose.family<PersonDetail, PersonDetailQuery>(
  (ref, query) => ref.watch(explorerRepositoryProvider).person(query.scope, query.personId),
);
