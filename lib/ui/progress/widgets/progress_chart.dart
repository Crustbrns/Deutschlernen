import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/domain/models/chart_bars.dart';

part 'progress_chart_painters.dart';

/// Stacked bars (known, started, reviewed, learned from the bottom — overlapping
/// layers, see [StatusCounts.stack]) joined by
/// translucent bands, so the eye follows each status from bar to bar. Every
/// non-empty segment shows its word count, so it is at least [_minSegment]
/// tall. The y axis and grid are linear (value × scale); a segment raised to
/// the minimum stands taller than its value — intended (user's choice).
/// Scrolls sideways when the bars don't fit; starts at the latest one.
class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key, required this.bars});

  final List<ChartBar> bars;

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
  static const _labelHeight = 34.0; // x labels, room for two lines
  static const _axisWidth = 34.0; // y labels
  static const _minSlot = 52.0; // narrower slots scroll instead
  static const _minSegment = 22.0; // fits a 14px count

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: AppPalette.of(context).mutedText,
    );
    final (:scale, :ticks) = _layout(bars);

    return SizedBox(
      height: _plotHeight + _labelHeight,
      child: Row(
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fits = bars.length * _minSlot <= constraints.maxWidth;
                final slot = fits
                    ? constraints.maxWidth / bars.length
                    : _minSlot;
                final plot = CustomPaint(
                  size: Size(slot * bars.length, _plotHeight + _labelHeight),
                  painter: _BarsPainter(
                    bars: bars,
                    slot: slot,
                    scale: scale,
                    segmentColors: [
                      for (final s in stackOrder) colorFor(s, context),
                    ],
                    labels: [
                      for (final b in bars)
                        AppStrings.of(context).dateShort(b.start),
                    ],
                    labelStyle: labelStyle,
                    gridColor: AppColors.divider(colors),
                  ),
                );
                return Stack(
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
                        // Opens at the right end: the latest weeks.
                        reverse: true,
                        child: plot,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Pixels per word and the grid values. Normally a round axis over the
  /// tallest total (0, 5, 10, 15, 20); if the minimum segment heights make a
  /// bar too tall for it, the scale shrinks to fit and the ticks follow.
  static ({double scale, List<int> ticks}) _layout(List<ChartBar> bars) {
    const height = _plotHeight - _topPadding;
    const lines = 4; // grid lines above 0
    final maxTotal = bars.fold(
      0,
      (m, b) => math.max(m, b.counts?.stackTotal ?? 0),
    );
    final roundTop = _niceStep(maxTotal / lines) * lines;
    final scale = math.min(height / roundTop, _fitScale(bars));
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
  /// segments raised to [_minSegment], still fits the plot.
  static double _fitScale(List<ChartBar> bars) {
    const height = _plotHeight - _topPadding;
    var scale = double.infinity;
    for (final bar in bars) {
      final values = bar.counts?.stack.where((v) => v > 0).toList() ?? [];
      if (values.isEmpty) continue;
      // Start proportional; segments that come out too small take the
      // minimum, the others share what is left. A few rounds settle it.
      var k = height / values.reduce((a, b) => a + b);
      for (var round = 0; round < values.length; round++) {
        final small = values.where((v) => v * k < _minSegment).length;
        final rest = values
            .where((v) => v * k >= _minSegment)
            .fold(0, (a, b) => a + b);
        if (rest == 0) break; // every segment at the minimum
        final next = (height - small * _minSegment) / rest;
        if (next == k) break;
        k = next;
      }
      scale = math.min(scale, k);
    }
    return scale;
  }

  static double segmentHeight(int value, double scale) =>
      value == 0 ? 0 : math.max(_minSegment, value * scale);
}
