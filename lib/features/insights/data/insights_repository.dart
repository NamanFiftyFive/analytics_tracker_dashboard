import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../workspace/domain/project_scope.dart';
import '../domain/overview_models.dart';

class InsightsRepository {
  InsightsRepository(this._api);

  final ApiClient _api;

  Future<Overview> overview(ProjectScope scope, OverviewRange range) => _api.get(
        '${scope.basePath}/insights/overview',
        (data) => Overview.fromJson(Map<String, dynamic>.from(data as Map)),
        query: {'range': range.apiValue},
      );
}

final insightsRepositoryProvider = Provider<InsightsRepository>(
  (ref) => InsightsRepository(ref.watch(apiClientProvider)),
);
