import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workspace/domain/project_scope.dart';
import '../data/insights_repository.dart';
import '../domain/overview_models.dart';

class OverviewQuery {
  const OverviewQuery(this.scope, this.range);

  final ProjectScope scope;
  final OverviewRange range;

  @override
  bool operator ==(Object other) => other is OverviewQuery && other.scope == scope && other.range == range;

  @override
  int get hashCode => Object.hash(scope, range);
}

/// Overview numbers for one project and range. Each project/range pair is cached separately,
/// so switching back to a range shows it instantly; pull-to-refresh reloads it.
final overviewProvider = FutureProvider.autoDispose.family<Overview, OverviewQuery>(
  (ref, query) => ref.watch(insightsRepositoryProvider).overview(query.scope, query.range),
);
