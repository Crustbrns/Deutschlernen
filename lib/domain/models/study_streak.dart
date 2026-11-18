import 'package:deutschlernen/domain/models/dates.dart';
import 'package:deutschlernen/domain/models/day_snapshot.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';

/// The daily streak: days in a row the user studied, i.e. reviewed a word or
/// took a new one to learn ("already know" doesn't count, user's choice).
class StudyStreak {
  StudyStreak._(this._days, this._today);

  /// Built from the daily [history] snapshots.
  factory StudyStreak.of(Map<DateTime, DaySnapshot> history, DateTime now) {
    final studied = <DateTime>{};
    StatusCounts? before;
    for (final day in history.keys.toList()..sort()) {
      final snapshot = history[day]!;
      final started = snapshot.counts.started > (before?.started ?? 0);
      if (started || snapshot.reviewedAfter(before) > 0) studied.add(day);
      before = snapshot.counts;
    }
    return StudyStreak._(studied, DateTime(now.year, now.month, now.day));
  }

  /// Studied days, at local midnight.
  final Set<DateTime> _days;
  final DateTime _today;

  bool get studiedToday => _days.contains(_today);

  /// Days in a row up to today. A day not studied yet doesn't break the
  /// streak before midnight: it then counts up to yesterday.
  int get current => _runBackFrom(studiedToday ? _today : addDays(_today, -1));

  /// The longest streak so far.
  int get best {
    var best = 0;
    for (final day in _days) {
      // Count each run once, from its last day.
      if (_days.contains(addDays(day, 1))) continue;
      final run = _runBackFrom(day);
      if (run > best) best = run;
    }
    return best;
  }

  /// This week, Monday to Sunday: studied or not.
  List<bool> get week {
    final monday = addDays(_today, -(_today.weekday - 1));
    return [for (var i = 0; i < 7; i++) _days.contains(addDays(monday, i))];
  }

  /// Today's place in [week]: 0 = Monday.
  int get todayIndex => _today.weekday - 1;

  int _runBackFrom(DateTime day) {
    var run = 0;
    while (_days.contains(addDays(day, -run))) {
      run++;
    }
    return run;
  }
}
