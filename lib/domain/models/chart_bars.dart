import 'dart:math' as math;

import 'package:deutschlernen/domain/models/day_snapshot.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';

/// Periods of the progress chart.
enum ChartPeriod {
  week, // 7 days, a bar per day
  month, // 30 days, a bar per day
  quarter, // 90 days, a bar per week (13)
  all; // from the first snapshot, a bar per month

  bool get byMonth => this == all;
}

/// One bar: what happened during its day, week or month, per chart layer
/// (bottom to top, as [StatusCounts.stack]). Null layers = before the
/// history starts; the slot stays empty.
typedef ChartBar = ({DateTime start, List<int>? layers});

/// Index of "reviewed" in [StatusCounts.stack].
const _reviewedLayer = 2;

/// Bars for [period] up to [now], built from daily [history] snapshots.
/// A bar shows only its own period: how much each layer grew since the end
/// of the previous one (drops count as 0), and the reviews done in it.
/// A day without a snapshot (app not opened) changed nothing.
List<ChartBar> chartBars(
  ChartPeriod period,
  Map<DateTime, DaySnapshot> history,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final days = history.keys.toList()..sort();

  // Counts at the end of [day]: the latest snapshot on or before it.
  StatusCounts? at(DateTime day) {
    StatusCounts? found;
    for (final d in days) {
      if (d.isAfter(day)) break;
      found = history[d]!.counts;
    }
    return found;
  }

  ChartBar bar((DateTime, DateTime) range) {
    final (start, end) = range;
    final after = at(end);
    if (after == null) return (start: start, layers: null);
    final layers = _gains(at(_addDays(start, -1)), after);
    // Every review counts, not only a word's first one. Days saved before
    // reviews were counted fall back to their first recalls.
    layers[_reviewedLayer] = [
      for (final d in days)
        if (!d.isBefore(start) && !d.isAfter(end))
          history[d]!.reviewed ??
              _gains(at(_addDays(d, -1)), history[d]!.counts)[_reviewedLayer],
    ].fold(0, (a, b) => a + b);
    return (start: start, layers: layers);
  }

  final ranges = switch (period) {
    ChartPeriod.week => _days(today, 7),
    ChartPeriod.month => _days(today, 30),
    ChartPeriod.quarter => _weeks(today, 13),
    ChartPeriod.all => _months(today, days.isEmpty ? today : days.first),
  };
  return [for (final r in ranges) bar(r)];
}

/// The newest snapshot (today's, written at start-up): the counts right
/// now. Zero counts before there is any history.
StatusCounts latestCounts(Map<DateTime, DaySnapshot> history) => history.isEmpty
    ? const StatusCounts()
    : history[history.keys.reduce((a, b) => a.isAfter(b) ? a : b)]!.counts;

/// Growth of each layer from [before] (null = nothing yet) to [after].
List<int> _gains(StatusCounts? before, StatusCounts after) => [
  for (var i = 0; i < after.stack.length; i++)
    math.max(0, after.stack[i] - (before?.stack[i] ?? 0)),
];

// Ranges (first day, last day) for the bars, oldest first; the last one
// ends today.
List<(DateTime, DateTime)> _days(DateTime today, int count) => [
  for (var i = count - 1; i >= 0; i--)
    (_addDays(today, -i), _addDays(today, -i)),
];

// Weeks start on Monday.
List<(DateTime, DateTime)> _weeks(DateTime today, int count) {
  final thisWeek = _addDays(today, -(today.weekday - 1));
  return [
    for (var i = count - 1; i >= 0; i--)
      (
        _addDays(thisWeek, -7 * i),
        i == 0 ? today : _addDays(thisWeek, -7 * i + 6),
      ),
  ];
}

// Calendar months from the one of [first].
List<(DateTime, DateTime)> _months(DateTime today, DateTime first) {
  final count = (today.year - first.year) * 12 + today.month - first.month + 1;
  return [
    for (var i = 0; i < count; i++)
      (
        DateTime(first.year, first.month + i),
        i == count - 1
            ? today
            // Day 0 of the next month = the last day of this one.
            : DateTime(first.year, first.month + i + 1, 0),
      ),
  ];
}

// Calendar days, not 24-hour steps: survives daylight saving changes.
DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
