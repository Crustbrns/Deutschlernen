import 'package:deutschlernen/domain/models/status_counts.dart';

/// Periods of the progress chart.
enum ChartPeriod {
  week, // 7 days, a bar per day
  month, // 30 days, a bar per week (5)
  quarter, // 90 days, a bar per week (13)
  all; // from the first snapshot, a bar per week

  bool get byDay => this == week;
}

/// One bar: the counts at the end of its day/week. Null counts = before the
/// history starts; the slot stays empty.
typedef ChartBar = ({DateTime start, StatusCounts? counts});

/// Bars for [period] up to [now], built from daily [history] snapshots.
/// A day without a snapshot (app not opened) has the counts of the last
/// snapshot before it: nothing changes while the app is closed.
List<ChartBar> chartBars(
  ChartPeriod period,
  Map<DateTime, StatusCounts> history,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final days = history.keys.toList()..sort();

  // Latest snapshot on or before [day].
  StatusCounts? at(DateTime day) {
    StatusCounts? found;
    for (final d in days) {
      if (d.isAfter(day)) break;
      found = history[d];
    }
    return found;
  }

  if (period.byDay) {
    return [
      for (var i = 6; i >= 0; i--)
        (start: _addDays(today, -i), counts: at(_addDays(today, -i))),
    ];
  }

  // Weeks start on Monday; the current week ends today.
  final thisWeek = _addDays(today, -(today.weekday - 1));
  final weekCount = switch (period) {
    ChartPeriod.month => 5,
    ChartPeriod.quarter => 13,
    _ when days.isEmpty => 1,
    // From the week of the first snapshot.
    _ => thisWeek.difference(_weekStart(days.first)).inDays ~/ 7 + 1,
  };
  return [
    for (var i = weekCount - 1; i >= 0; i--)
      () {
        final start = _addDays(thisWeek, -7 * i);
        final end = i == 0 ? today : _addDays(start, 6);
        return (start: start, counts: at(end));
      }(),
  ];
}

/// The newest snapshot (today's, written at start-up): the counts right
/// now. Zero counts before there is any history.
StatusCounts latestCounts(Map<DateTime, StatusCounts> history) =>
    history.isEmpty
    ? const StatusCounts()
    : history[history.keys.reduce((a, b) => a.isAfter(b) ? a : b)]!;

DateTime _weekStart(DateTime d) => _addDays(d, -(d.weekday - 1));

// Calendar days, not 24-hour steps: survives daylight saving changes.
DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
