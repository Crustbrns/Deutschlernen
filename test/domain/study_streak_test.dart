import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/day_snapshot.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';
import 'package:deutschlernen/domain/models/study_streak.dart';

void main() {
  // Wednesday 2026-11-18, mid-day.
  final now = DateTime(2026, 11, 18, 14, 30);
  DateTime day(int d) => DateTime(2026, 11, d);

  /// [started] words taken to learn so far, [reviewed] reviews that day.
  DaySnapshot snap(int started, {int reviewed = 0, int known = 0}) =>
      DaySnapshot(
        StatusCounts(learning: started, known: known),
        reviewed: reviewed,
      );

  test('days in a row up to today', () {
    final streak = StudyStreak.of({
      day(16): snap(2),
      day(17): snap(2, reviewed: 3), // reviews only
      day(18): snap(5), // new words only
    }, now);

    expect(streak.studiedToday, isTrue);
    expect(streak.current, 3);
  });

  test('not studied yet today: the streak holds until midnight', () {
    final streak = StudyStreak.of({
      day(16): snap(2),
      day(17): snap(4),
      day(18): snap(4), // app opened, nothing done
    }, now);

    expect(streak.studiedToday, isFalse);
    expect(streak.current, 2);
  });

  test('a missed day breaks it; the best run is kept', () {
    final streak = StudyStreak.of({
      day(10): snap(1),
      day(11): snap(2),
      day(12): snap(3),
      day(14): snap(4), // 13th missed
      day(17): snap(5), // 15th and 16th missed
      day(18): snap(6),
    }, now);

    expect(streak.current, 2);
    expect(streak.best, 3);
  });

  test('"already know" alone is not studying', () {
    final streak = StudyStreak.of({
      day(17): snap(2),
      day(18): snap(2, known: 5),
    }, now);

    expect(streak.studiedToday, isFalse);
    expect(streak.current, 1);
  });

  test('days saved before reviews were counted use first recalls', () {
    final streak = StudyStreak.of({
      day(16): const DaySnapshot(StatusCounts(learning: 2)),
      day(17): const DaySnapshot(StatusCounts(learning: 1, review: 1)),
    }, now);

    expect(streak.current, 2); // 17th: one word recalled, nothing started
  });

  test('week: Monday to Sunday, today Wednesday', () {
    final streak = StudyStreak.of({
      day(15): snap(1), // Sunday before: not this week
      day(16): snap(2),
      day(18): snap(3),
    }, now);

    expect(streak.week, [true, false, true, false, false, false, false]);
    expect(streak.todayIndex, 2);
  });

  test('no history: no streak', () {
    final streak = StudyStreak.of({}, now);

    expect(streak.current, 0);
    expect(streak.best, 0);
  });
}
