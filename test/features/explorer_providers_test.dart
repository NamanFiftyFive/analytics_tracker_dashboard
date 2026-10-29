import 'package:analytics_tracker/features/explorer/application/explorer_providers.dart';
import 'package:analytics_tracker/features/workspace/domain/project_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_server.dart';
import '../helpers/test_app.dart';

/// A container where [provider] stays alive, as it does while its screen is open
/// (the lists are autoDispose, so an unwatched one would be thrown away between calls).
Future<ProviderContainer> watching(FakeServer server, ProviderListenable<Object?> provider) async {
  final container = await makeContainer(server);
  container.listen(provider, (_, _) {});
  return container;
}

/// Paging rules of the Events and Users lists, without any screen.
void main() {
  const scope = ProjectScope(organizationId: 'org-1', projectId: 'proj-1');

  group('event feed', () {
    const query = EventFeedQuery(scope);

    test('loadMore asks for older events with the cursor and appends them', () async {
      final server = happyServer();
      server.on('GET', '$projectPath/events', (request) => request.queryParameters['cursor'] == 'c2'
          ? FakeResponse.ok(eventPageJson(items: [eventJson(id: 'old', name: 'older')]))
          : FakeResponse.ok(eventPageJson(nextCursor: 'c2')));
      final container = await watching(server, eventFeedProvider(query));

      final first = await container.read(eventFeedProvider(query).future);
      expect((first.items.length, first.hasMore), (2, true));

      await container.read(eventFeedProvider(query).notifier).loadMore();
      final state = container.read(eventFeedProvider(query)).value!;
      expect(state.items.map((e) => e.id), ['e2', 'e1', 'old']);
      expect(state.hasMore, isFalse);
      expect(server.calls('GET', '$projectPath/events').last.queryParameters['cursor'], 'c2');
    });

    test('at the end, loadMore sends no request', () async {
      final server = happyServer(); // next_cursor null
      final container = await watching(server, eventFeedProvider(query));
      await container.read(eventFeedProvider(query).future);
      await container.read(eventFeedProvider(query).notifier).loadMore();
      expect(server.calls('GET', '$projectPath/events'), hasLength(1));
    });

    test('a failed loadMore keeps what is shown and waits for a refresh', () async {
      final server = happyServer();
      server.sequence('GET', '$projectPath/events', [
        FakeResponse.ok(eventPageJson(nextCursor: 'c2')),
        FakeResponse.error(500, 'Internal server error'),
        FakeResponse.ok(eventPageJson(nextCursor: 'c2')),
      ]);
      final container = await watching(server, eventFeedProvider(query));
      await container.read(eventFeedProvider(query).future);

      await container.read(eventFeedProvider(query).notifier).loadMore();
      final state = container.read(eventFeedProvider(query)).value!;
      expect((state.items.length, state.loadMoreFailed, state.loadingMore), (2, true, false));

      // More scrolling doesn't hit the failing server again...
      await container.read(eventFeedProvider(query).notifier).loadMore();
      expect(server.calls('GET', '$projectPath/events'), hasLength(2));

      // ...pull-to-refresh starts the list over.
      container.invalidate(eventFeedProvider(query));
      final refreshed = await container.read(eventFeedProvider(query).future);
      expect((refreshed.loadMoreFailed, refreshed.hasMore), (false, true));
    });

    test('filters and search are sent to the server', () async {
      final server = happyServer();
      final container = await makeContainer(server);
      const filtered = EventFeedQuery(scope, eventName: 'car_liked', search: 'pune');
      await container.read(eventFeedProvider(filtered).future);
      final params = server.calls('GET', '$projectPath/events').single.queryParameters;
      expect((params['event'], params['search']), ('car_liked', 'pune'));
    });
  });

  group('users list', () {
    const query = PersonListQuery(scope);

    test('hasMore comes from the total; loadMore asks for the next offset', () async {
      final server = happyServer();
      final page1 = [for (var i = 0; i < 50; i++) personJson(id: 'p$i', distinctId: 'u$i')];
      server.on('GET', '$projectPath/persons', (request) => request.queryParameters['offset'] == 50
          ? FakeResponse.ok(personPageJson(items: [personJson(id: 'p50', distinctId: 'u50')], total: 51))
          : FakeResponse.ok(personPageJson(items: page1, total: 51)));
      final container = await watching(server, personListProvider(query));

      expect((await container.read(personListProvider(query).future)).hasMore, isTrue);
      await container.read(personListProvider(query).notifier).loadMore();

      final state = container.read(personListProvider(query)).value!;
      expect((state.items.length, state.hasMore), (51, false));
      expect(state.counts.all, 3, reason: 'tab counts come along with every page');
      final calls = server.calls('GET', '$projectPath/persons');
      expect(calls.map((r) => r.queryParameters['offset']), [0, 50]);
    });

    test('a failed loadMore keeps the users shown', () async {
      final server = happyServer();
      server.sequence('GET', '$projectPath/persons', [
        FakeResponse.ok(personPageJson(total: 10)),
        FakeResponse.error(503, 'Database unavailable'),
      ]);
      final container = await watching(server, personListProvider(query));
      await container.read(personListProvider(query).future);
      await container.read(personListProvider(query).notifier).loadMore();

      final state = container.read(personListProvider(query)).value!;
      expect((state.items.length, state.loadMoreFailed, state.hasMore), (2, true, true));

      await container.read(personListProvider(query).notifier).loadMore();
      expect(server.calls('GET', '$projectPath/persons'), hasLength(2), reason: 'no retry until refresh');
    });

    test('nothing more to load sends no request', () async {
      final server = happyServer(); // total == items
      final container = await watching(server, personListProvider(query));
      await container.read(personListProvider(query).future);
      await container.read(personListProvider(query).notifier).loadMore();
      expect(server.calls('GET', '$projectPath/persons'), hasLength(1));
    });
  });

  test('queries with the same values are the same list (cached, not refetched)', () {
    expect(const EventFeedQuery(scope, search: 'a'), const EventFeedQuery(scope, search: 'a'));
    expect(const EventFeedQuery(scope, search: 'a').hashCode, const EventFeedQuery(scope, search: 'a').hashCode);
    expect(const PersonListQuery(scope), isNot(const PersonListQuery(scope, search: 'x')));
    expect(const PersonDetailQuery(scope, 'p1'), const PersonDetailQuery(scope, 'p1'));
  });
}
