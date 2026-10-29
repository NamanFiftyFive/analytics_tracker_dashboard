import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/format/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../insights/domain/overview_models.dart';

/// Simple bar chart of events per day, built from plain widgets (no chart package):
/// the busiest day is full height, the latest day is highlighted.
class EventsBarChart extends StatelessWidget {
  const EventsBarChart({super.key, required this.points, required this.range});

  final List<DayPoint> points;
  final OverviewRange range;

  static const _height = 120.0;

  @override
  Widget build(BuildContext context) {
    final format = Formatters.of(context);
    final colors = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    if (points.isEmpty) return const SizedBox(height: _height);

    final maxEvents = max(1, points.map((p) => p.events).reduce(max));
    final total = points.fold<int>(0, (sum, p) => sum + p.events);
    final showEveryLabel = points.length <= 7;
    final gap = points.length > 31 ? 1.0 : 4.0;

    return Semantics(
      label: '${format.number(total)} · ${format.shortDate(points.first.day)} – ${format.shortDate(points.last.day)}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(format.number(maxEvents), style: TextStyle(fontSize: 11, color: colors.muted)),
            ),
            SizedBox(
              height: _height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < points.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: gap / 2),
                        child: Container(
                          key: Key('bar-$i'),
                          height: max(2, _height * points[i].events / maxEvents),
                          decoration: BoxDecoration(
                            color: i == points.length - 1 ? accent : accent.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(range == OverviewRange.days90 ? 1 : 4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showEveryLabel)
              Row(
                children: [
                  for (final point in points)
                    Expanded(
                      child: Text(
                        format.weekday(point.day),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: colors.muted),
                      ),
                    ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(format.shortDate(points.first.day), style: TextStyle(fontSize: 11, color: colors.muted)),
                  Text(format.shortDate(points.last.day), style: TextStyle(fontSize: 11, color: colors.muted)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
