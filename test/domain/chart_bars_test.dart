import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/chart_bars.dart';
import 'package:deutschlernen/domain/models/day_snapshot.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';

void main() {
  // Wednesday 2026-11-18, mid-day: the week started on Monday the 16th.
  final now = DateTime(2026, 11, 18, 14, 30);

  // Layers: known, started, reviewed, learned.
  List<List<int>?> layers(List<ChartBar> bars) => [
    for (final b in bars) b.layers,
  ];

  test('week: 7 daily bars ending today, empty before the history', () {
    final bars = chartBars(ChartPeriod.week, {}, now);

    expect(bars, hasLength(7));
    expect(bars.first.start, DateTime(2026, 11, 12));
    expect(bars.last.start, DateTime(2026, 11, 18));
    expect(bars.every((b) => b.layers == null), isTrue);
  });

  test('a day shows only its own growth; drops count as 0', () {
    final bars = chartBars(ChartPeriod.week, {
      DateTime(2026, 11, 13): const DaySnapshot(StatusCounts(learning: 2)),
      DateTime(2026, 11, 16): const DaySnapshot(
        StatusCounts(known: 1, learning: 5),
      ),
      // Two pink words recalled; no review count saved yet.
      DateTime(2026, 11, 17): const DaySnapshot(
        StatusCounts(known: 1, learning: 3, review: 2),
      ),
      // Known word reset, one word learned, 4 words reviewed.
      DateTime(2026, 11, 18): const DaySnapshot(
        StatusCounts(learning: 3, review: 1, learned: 1),
        reviewed: 4,
      ),
    }, now);

    expect(layers(bars), [
      null, // 12th: before the history starts
      [0, 2, 0, 0],
      [0, 0, 0, 0], // app not opened
      [0, 0, 0, 0],
      [1, 3, 0, 0],
      [0, 0, 2, 0], // first recalls stand in for the missing count
      [0, 0, 4, 1],
    ]);
  });

  test('30 days: a bar per day', () {
    final bars = chartBars(ChartPeriod.month, {}, now);

    expect(bars, hasLength(30));
    expect(bars.first.start, DateTime(2026, 10, 20));
    expect(bars.last.start, DateTime(2026, 11, 18));
  });

  test('90 days: weekly bars from Monday, reviews summed over the week', () {
    final bars = chartBars(ChartPeriod.quarter, {
      DateTime(2026, 11, 10): const DaySnapshot(StatusCounts(learning: 2)),
      DateTime(2026, 11, 15): const DaySnapshot(
        StatusCounts(learning: 4),
        reviewed: 3,
      ),
      DateTime(2026, 11, 17): const DaySnapshot(
        StatusCounts(learning: 7),
        reviewed: 1,
      ),
      DateTime(2026, 11, 18): const DaySnapshot(
        StatusCounts(learning: 7),
        reviewed: 2,
      ),
    }, now);

    expect(bars, hasLength(13));
    expect(bars.every((b) => b.start.weekday == DateTime.monday), isTrue);
    expect(bars.last.start, DateTime(2026, 11, 16));
    expect(layers(bars).sublist(11), [
      [0, 4, 3, 0], // Nov 9–15
      [0, 3, 3, 0], // Nov 16–18: growth since Sunday the 15th
    ]);
  });

  test('all time: monthly bars from the month of the first snapshot', () {
    final bars = chartBars(ChartPeriod.all, {
      DateTime(2026, 10, 20): const DaySnapshot(StatusCounts(learning: 2)),
      DateTime(2026, 11, 3): const DaySnapshot(StatusCounts(learning: 5)),
    }, now);

    expect(
      [for (final b in bars) b.start],
      [DateTime(2026, 10, 1), DateTime(2026, 11, 1)],
    );
    expect(layers(bars), [
      [0, 2, 0, 0],
      [0, 3, 0, 0],
    ]);
    expect(chartBars(ChartPeriod.all, {}, now), hasLength(1));
  });

  test('period totals: each layer summed over the bars', () {
    final bars = <ChartBar>[
      (start: DateTime(2026, 11, 16), layers: null),
      (start: DateTime(2026, 11, 17), layers: [1, 3, 0, 0]),
      (start: DateTime(2026, 11, 18), layers: [0, 2, 4, 1]),
    ];

    expect(periodTotals(bars), [1, 5, 4, 1]);
    expect(periodTotals([]), [0, 0, 0, 0]);
  });

  test('latest counts: the newest snapshot, whatever the map order', () {
    const one = StatusCounts(known: 1);
    const two = StatusCounts(known: 2);

    expect(
      latestCounts({
        DateTime(2026, 11, 18): const DaySnapshot(two),
        DateTime(2026, 11, 13): const DaySnapshot(one),
      }),
      two,
    );
    expect(latestCounts({}).stack, [0, 0, 0, 0]);
  });
}
