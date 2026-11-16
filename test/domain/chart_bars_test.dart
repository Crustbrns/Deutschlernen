import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/chart_bars.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';

void main() {
  // Wednesday 2026-11-18, mid-day: the week started on Monday the 16th.
  final now = DateTime(2026, 11, 18, 14, 30);
  const one = StatusCounts(known: 1);
  const two = StatusCounts(known: 2);

  test('week: 7 daily bars ending today', () {
    final bars = chartBars(ChartPeriod.week, {}, now);

    expect(bars, hasLength(7));
    expect(bars.first.start, DateTime(2026, 11, 12));
    expect(bars.last.start, DateTime(2026, 11, 18));
    expect(bars.every((b) => b.counts == null), isTrue);
  });

  test('a day without a snapshot keeps the last one before it', () {
    final bars = chartBars(ChartPeriod.week, {
      DateTime(2026, 11, 13): one,
      DateTime(2026, 11, 16): two,
    }, now);

    expect(
      [for (final b in bars) b.counts],
      [
        null, // 12th: before the history starts
        one,
        one,
        one,
        two,
        two,
        two,
      ],
    );
  });

  test('month and quarter: weekly bars starting on Monday', () {
    final month = chartBars(ChartPeriod.month, {}, now);
    final quarter = chartBars(ChartPeriod.quarter, {}, now);

    expect(month, hasLength(5));
    expect(quarter, hasLength(13));
    expect(month.last.start, DateTime(2026, 11, 16));
    expect(month.every((b) => b.start.weekday == DateTime.monday), isTrue);
  });

  test('a past week shows its Sunday, the current week today', () {
    final bars = chartBars(ChartPeriod.month, {
      DateTime(2026, 11, 15): one, // Sunday of the previous week
      DateTime(2026, 11, 18): two,
    }, now);

    expect(bars[bars.length - 2].counts, one);
    expect(bars.last.counts, two);
  });

  test('all time: from the week of the first snapshot', () {
    final bars = chartBars(ChartPeriod.all, {DateTime(2026, 11, 3): one}, now);

    expect(bars, hasLength(3)); // weeks of Nov 2, 9, 16
    expect(bars.first.start, DateTime(2026, 11, 2));
    expect(chartBars(ChartPeriod.all, {}, now), hasLength(1));
  });
}
