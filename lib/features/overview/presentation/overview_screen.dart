import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../insights/application/overview_provider.dart';
import '../../insights/domain/overview_models.dart';
import '../../workspace/application/project_scope_provider.dart';
import '../../workspace/application/workspace_controller.dart';
import '../../workspace/domain/workspace_models.dart';
import '../../workspace/presentation/project_switcher.dart';
import 'events_bar_chart.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  OverviewRange _range = OverviewRange.days7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final workspace = ref.watch(workspaceControllerProvider);
    final scope = ref.watch(projectScopeProvider);
    final controller = ref.read(workspaceControllerProvider.notifier);

    return Scaffold(
      body: workspace.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SafeArea(
          child: EmptyState(
            icon: Icons.cloud_off,
            title: l10n.loadFailedTitle,
            body: errorMessage(l10n, error),
            action: OutlinedButton(onPressed: controller.reload, child: Text(l10n.retry)),
          ),
        ),
        data: (data) {
          if (data == null) {
            return SafeArea(
              child: EmptyState(icon: Icons.apartment, title: l10n.noOrganizationsTitle, body: l10n.noOrganizationsBody),
            );
          }
          final query = scope == null ? null : OverviewQuery(scope, _range);
          return RefreshIndicator(
            onRefresh: () async {
              if (query == null) return controller.reload();
              ref.invalidate(overviewProvider(query));
              await ref.read(overviewProvider(query).future).catchError((_) => _emptyOverview);
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Header(
                  workspace: data,
                  range: _range,
                  onRangeChanged: (range) => setState(() => _range = range),
                  onPickProject: data.projects.length > 1 ? () => showProjectPicker(context, ref) : null,
                ),
                if (query == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: EmptyState(icon: Icons.phone_iphone, title: l10n.noProjectsTitle, body: l10n.noProjectsBody),
                  )
                else
                  _OverviewBody(query: query),
              ],
            ),
          );
        },
      ),
    );
  }

  static const _emptyOverview = Overview(
    activeUsers: Kpi(value: 0, previous: 0),
    events: Kpi(value: 0, previous: 0),
    sessions: Kpi(value: 0, previous: 0),
    avgSessionSeconds: Kpi(value: 0, previous: 0),
    eventsPerDay: [],
    topScreens: [],
    topEvents: [],
  );

}

class _Header extends StatelessWidget {
  const _Header({required this.workspace, required this.range, required this.onRangeChanged, this.onPickProject});

  final Workspace workspace;
  final OverviewRange range;
  final ValueChanged<OverviewRange> onRangeChanged;
  final VoidCallback? onPickProject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final project = workspace.selectedProject;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Semantics(
            button: onPickProject != null,
            label: onPickProject != null ? l10n.switchProject : null,
            child: InkWell(
              onTap: onPickProject,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(workspace.organization.name,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.muted)),
                          Text(
                            project?.name ?? l10n.noProjectsTitle,
                            key: const Key('overview-project-name'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (onPickProject != null) const Icon(Icons.expand_more),
                  ],
                ),
              ),
            ),
          ),
          if (project != null)
            SegmentedButton<OverviewRange>(
              key: const Key('overview-range'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: OverviewRange.today, label: Text(l10n.rangeToday)),
                ButtonSegment(value: OverviewRange.days7, label: Text(l10n.range7Days)),
                ButtonSegment(value: OverviewRange.days30, label: Text(l10n.range30Days)),
                ButtonSegment(value: OverviewRange.days90, label: Text(l10n.range90Days)),
              ],
              selected: {range},
              onSelectionChanged: (selection) => onRangeChanged(selection.first),
            ),
        ],
      ),
    );
  }
}

class _OverviewBody extends ConsumerWidget {
  const _OverviewBody({required this.query});

  final OverviewQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(overviewProvider(query));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: overview.when(
        // Keep showing the previous numbers while a new range loads, so the page doesn't jump.
        skipLoadingOnReload: true,
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 64),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => EmptyState(
          icon: Icons.cloud_off,
          title: l10n.loadFailedTitle,
          body: errorMessage(l10n, error),
          action: OutlinedButton(onPressed: () => ref.invalidate(overviewProvider(query)), child: Text(l10n.retry)),
        ),
        data: (data) => _OverviewContent(data: data, range: query.range),
      ),
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.data, required this.range});

  final Overview data;
  final OverviewRange range;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = Formatters.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _KpiRow(
          left: _KpiCard(keyName: 'kpi-active-users', label: l10n.kpiActiveUsers, value: format.number(data.activeUsers.value), kpi: data.activeUsers),
          right: _KpiCard(keyName: 'kpi-events', label: l10n.kpiEvents, value: format.number(data.events.value), kpi: data.events),
        ),
        _KpiRow(
          left: _KpiCard(keyName: 'kpi-sessions', label: l10n.kpiSessions, value: format.number(data.sessions.value), kpi: data.sessions),
          right: _KpiCard(
            keyName: 'kpi-avg-session',
            label: l10n.kpiAvgSession,
            value: format.duration(data.avgSessionSeconds.value),
            kpi: data.avgSessionSeconds,
          ),
        ),
        if (data.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: colors.warningSoft, borderRadius: BorderRadius.circular(12)),
            child: Row(
              spacing: 10,
              children: [
                Icon(Icons.info_outline, color: colors.warning, size: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(l10n.noEventsYetTitle, style: TextStyle(fontWeight: FontWeight.w700, color: colors.warning)),
                      Text(l10n.noEventsYetBody, style: TextStyle(fontSize: 13, color: colors.warning)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        _SectionCard(
          title: l10n.eventsPerDayTitle,
          child: EventsBarChart(points: data.eventsPerDay, range: range),
        ),
        _SectionCard(
          title: l10n.topScreensTitle,
          trailing: TextButton(onPressed: () => context.go(Routes.events), child: Text(l10n.seeEvents)),
          child: data.topScreens.isEmpty
              ? _Muted(l10n.noDataForRange)
              : Column(
                  spacing: 12,
                  children: [
                    for (final screen in data.topScreens)
                      _RankedBar(
                        label: screen.screenName,
                        value: l10n.viewsCount(screen.views),
                        fraction: screen.views / data.topScreens.first.views,
                      ),
                  ],
                ),
        ),
        _SectionCard(
          title: l10n.topEventsTitle,
          child: data.topEvents.isEmpty
              ? _Muted(l10n.noDataForRange)
              : Column(
                  children: [
                    for (final event in data.topEvents)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: Text(event.eventName,
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(format.number(event.count), style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(l10n.usersCount(event.users), style: TextStyle(fontSize: 13, color: colors.muted)),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [Expanded(child: left), Expanded(child: right)],
        ),
      );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.keyName, required this.label, required this.value, required this.kpi});

  final String keyName;
  final String label;
  final String value;
  final Kpi kpi;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final change = kpi.changePercent;
    final up = (change ?? 0) >= 0;
    return Card(
      key: Key(keyName),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.muted)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
            if (change != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: up ? colors.successSoft : colors.warningSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  Formatters.of(context).change(change),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: up ? colors.success : colors.warning),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                    ?trailing,
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
      );
}

class _RankedBar extends StatelessWidget {
  const _RankedBar({required this.label, required this.value, required this.fraction});

  final String label;
  final String value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            minHeight: 6,
            backgroundColor: colors.fill,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(color: context.colors.muted));
}
