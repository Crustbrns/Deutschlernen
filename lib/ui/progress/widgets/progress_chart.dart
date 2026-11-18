import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/domain/models/chart_bars.dart';

part 'progress_chart_painters.dart';

/// Stacked bars (known, started, reviewed, learned from the bottom: what was
/// done in each day, week or month, see [chartBars]) joined by
/// translucent bands, so the eye follows each status from bar to bar. Every
/// non-empty segment shows its word count and is at least as tall as the
/// bar is wide (a square, user's choice). The y axis and grid are linear (value × scale); a segment raised to
/// the minimum stands taller than its value — intended (user's choice).
/// Scrolls sideways when the bars don't fit; starts at the latest one.
class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key, required this.bars, this.byMonth = false});

  final List<ChartBar> bars;

  /// Labels name the month ("ноя") instead of the day ("16 ноя").
  final bool byMonth;

  /// Bottom to top.
  static const stackOrder = [
    WordStatus.known,
    WordStatus.learning,
    WordStatus.review,
    WordStatus.learned,
  ];

  /// Chart and legend color of a status: the list strip colors, except
  /// "already know", which is gray here (white in the lists).
  static Color colorFor(WordStatus status, BuildContext context) =>
      status == WordStatus.known
      ? AppColors.chartKnown
      : AppColors.forWordStatus(status, Theme.of(context).colorScheme);

  static const _plotHeight = 220.0;
  static const _topPadding = 8.0; // keeps the tallest bar off the edge
  static const _labelGap = 3.0; // between the grid and the dates
  static const _labelHeight = 37.0; // x labels: the gap and two lines
  static const _axisWidth = 34.0; // y labels
  static const _minSlot = 36.0; // narrower slots scroll instead
  static const _maxBarWidth = 28.0;
  static const _headroom = 1.5; // axis top = tallest bar × this

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: AppPalette.of(context).mutedText,
    );

    return SizedBox(
      height: _plotHeight + _labelHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - _axisWidth;
          final fits = bars.length * _minSlot <= width;
          final slot = fits ? width / bars.length : _minSlot;
          final barWidth = math.min(slot * 0.8, _maxBarWidth);
          // At least square: the gap between segments comes off the height.
          final minSegment = barWidth + _BarsPainter._gap;
          final (:scale, :ticks) = _layout(bars, minSegment);
          final plot = CustomPaint(
            size: Size(slot * bars.length, _plotHeight + _labelHeight),
            painter: _BarsPainter(
              bars: bars,
              slot: slot,
              barWidth: barWidth,
              minSegment: minSegment,
              scale: scale,
              segmentColors: [for (final s in stackOrder) colorFor(s, context)],
              labels: [
                for (final b in bars)
                  byMonth
                      ? AppStrings.of(context).monthShort(b.start)
                      : AppStrings.of(context).dateShort(b.start),
              ],
              labelStyle: labelStyle,
              gridColor: AppColors.divider(colors),
            ),
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _axisWidth,
                child: CustomPaint(
                  painter: _AxisPainter(
                    ticks: ticks,
                    scale: scale,
                    style: labelStyle,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    // Grid stays put while the bars scroll over it.
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPainter(
                          ticks: ticks,
                          scale: scale,
                          color: AppColors.divider(colors),
                        ),
                      ),
                    ),
                    if (fits)
                      plot
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        // Opens at the right end: the latest bars.
                        reverse: true,
                        child: plot,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Pixels per word and the grid values. Normally a round axis over the
  /// tallest total × [_headroom] (0, 10, 20, 30); if the minimum segment
  /// heights make a bar too tall for it, the scale shrinks so the bar still
  /// leaves that headroom, and the ticks follow.
  static ({double scale, List<int> ticks}) _layout(
    List<ChartBar> bars,
    double minSegment,
  ) {
    const height = _plotHeight - _topPadding;
    const lines = 4; // grid lines above 0
    final maxTotal = bars.fold(
      0,
      (m, b) => math.max(m, b.layers?.fold<int>(0, (a, v) => a + v) ?? 0),
    );
    final roundTop = _niceStep(maxTotal * _headroom / lines) * lines;
    final scale = math.min(
      height / roundTop,
      _fitScale(bars, minSegment, height / _headroom),
    );
    // Round step that puts at most [lines] lines into the plot.
    final top = height / scale;
    final step = _niceStep(top / lines);
    return (scale: scale, ticks: [for (var v = 0; v <= top; v += step) v]);
  }

  /// Smallest of 1, 2, 5, 10, 20, 50, … that is ≥ [x].
  static int _niceStep(double x) {
    for (var base = 1; ; base *= 10) {
      for (final m in const [1, 2, 5]) {
        if (m * base >= x) return m * base;
      }
    }
  }

  static double y(int value, double scale) => _plotHeight - value * scale;

  /// The largest pixels-per-word at which every bar, with its small
  /// segments raised to [minSegment], is at most [height] tall.
  static double _fitScale(
    List<ChartBar> bars,
    double minSegment,
    double height,
  ) {
    var scale = double.infinity;
    for (final bar in bars) {
      final values = bar.layers?.where((v) => v > 0).toList() ?? [];
      if (values.isEmpty) continue;
      // Start proportional; segments that come out too small take the
      // minimum, the others share what is left. A few rounds settle it.
      var k = height / values.reduce((a, b) => a + b);
      for (var round = 0; round < values.length; round++) {
        final small = values.where((v) => v * k < minSegment).length;
        final rest = values
            .where((v) => v * k >= minSegment)
            .fold(0, (a, b) => a + b);
        if (rest == 0) break; // every segment at the minimum
        final next = (height - small * minSegment) / rest;
        if (next == k) break;
        k = next;
      }
      scale = math.min(scale, k);
    }
    return scale;
  }

  static double segmentHeight(int value, double scale, double minSegment) =>
      value == 0 ? 0 : math.max(minSegment, value * scale);
}
