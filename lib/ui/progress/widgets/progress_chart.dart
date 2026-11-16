import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/domain/models/chart_bars.dart';

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

/// Y labels, centered on their grid lines.
class _AxisPainter extends CustomPainter {
  _AxisPainter({required this.ticks, required this.scale, required this.style});

  final List<int> ticks;
  final double scale;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    for (final t in ticks) {
      final tp = TextPainter(
        text: TextSpan(text: '$t', style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, ProgressChart.y(t, scale) - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_AxisPainter old) =>
      !listEquals(old.ticks, ticks) || old.scale != scale || old.style != style;
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.ticks, required this.scale, required this.color});

  final List<int> ticks;
  final double scale;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (final t in ticks) {
      final y = ProgressChart.y(t, scale);
      // Dashed: quieter than solid lines behind the bars.
      for (var x = 0.0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      !listEquals(old.ticks, ticks) || old.scale != scale || old.color != color;
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.bars,
    required this.slot,
    required this.scale,
    required this.segmentColors,
    required this.labels,
    required this.labelStyle,
    required this.gridColor,
  });

  final List<ChartBar> bars;
  final double slot;
  final double scale; // pixels per word, see ProgressChart._layout
  final List<Color> segmentColors;
  final List<String> labels; // "16 ноя", one per bar
  final TextStyle labelStyle;
  final Color gridColor; // vertical dashes, same as the horizontal grid

  static const _gap = 2.0; // between stacked segments
  static const _radius = Radius.circular(6);
  static const _bandAlpha = 0.22;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = math.min(slot * 0.62, 44.0);

    // Segment edges of each bar: [(bottom, top)] per status, in pixels.
    List<(double, double)>? edges(ChartBar bar) {
      final counts = bar.counts;
      if (counts == null || counts.total == 0) return null;
      var y = ProgressChart._plotHeight;
      return [
        for (final v in counts.stack)
          (y, y -= ProgressChart.segmentHeight(v, scale)),
      ];
    }

    final all = [for (final b in bars) edges(b)];

    // Vertical grid: dashed lines between columns, like the horizontal
    // ones. Drawn here, not in _GridPainter, so they scroll with the bars.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 1; i < bars.length; i++) {
      final x = slot * i;
      for (var y = 0.0; y < ProgressChart._plotHeight; y += 8) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, math.min(y + 4, ProgressChart._plotHeight)),
          gridPaint,
        );
      }
    }

    // Bands first, so the bars cover their ends.
    for (var i = 0; i + 1 < bars.length; i++) {
      final a = all[i], b = all[i + 1];
      if (a == null || b == null) continue;
      final x0 = slot * i + (slot + barWidth) / 2;
      final x1 = slot * (i + 1) + (slot - barWidth) / 2;
      final mid = (x0 + x1) / 2;
      for (var s = 0; s < a.length; s++) {
        final (aBottom, aTop) = _inset(a[s]);
        final (bBottom, bTop) = _inset(b[s]);
        // Nothing to join when the status is empty on both sides.
        if (aBottom <= aTop && bBottom <= bTop) continue;
        final path = Path()
          ..moveTo(x0, aTop)
          ..cubicTo(mid, aTop, mid, bTop, x1, bTop)
          ..lineTo(x1, bBottom)
          ..cubicTo(mid, bBottom, mid, aBottom, x0, aBottom)
          ..close();
        canvas.drawPath(
          path,
          Paint()..color = segmentColors[s].withValues(alpha: _bandAlpha),
        );
      }
    }

    // Dates: one line ("16 ноя") if every label fits its column, else all
    // in two (day over month), so the row looks the same throughout.
    TextPainter dateLabel(String text) => TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    var dates = [for (final l in labels) dateLabel(l)];
    if (dates.any((tp) => tp.width > slot - 4)) {
      dates = [for (final l in labels) dateLabel(l.replaceFirst(' ', '\n'))];
    }

    for (var i = 0; i < bars.length; i++) {
      final left = slot * i + (slot - barWidth) / 2;
      final e = all[i];
      if (e != null) {
        for (var s = 0; s < e.length; s++) {
          final (bottom, segTop) = _inset(e[s]);
          if (bottom <= segTop) continue; // empty status
          canvas.drawRRect(
            RRect.fromLTRBR(left, segTop, left + barWidth, bottom, _radius),
            Paint()..color = segmentColors[s],
          );
          _paintCount(
            canvas,
            bars[i].counts!.stack[s],
            Rect.fromLTRB(left, segTop, left + barWidth, bottom),
          );
        }
      }

      final tp = dates[i];
      tp.paint(
        canvas,
        Offset(
          slot * i + (slot - tp.width) / 2,
          ProgressChart._plotHeight +
              (ProgressChart._labelHeight - tp.height) / 2,
        ),
      );
    }
  }

  /// The word count in the middle of a segment, black regular. Segments are
  /// tall enough; only a too narrow bar skips it.
  void _paintCount(Canvas canvas, int value, Rect rect) {
    final tp = TextPainter(
      text: TextSpan(
        text: '$value',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          color: AppColors.chartCount,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (tp.width + 4 > rect.width) return;
    tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
  }

  // Leaves a thin gap between stacked segments.
  static (double, double) _inset((double, double) e) =>
      (e.$1 - _gap / 2, e.$2 + _gap / 2);

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.bars != bars ||
      old.slot != slot ||
      old.scale != scale ||
      !listEquals(old.labels, labels) ||
      old.labelStyle != labelStyle ||
      old.gridColor != gridColor ||
      !listEquals(old.segmentColors, segmentColors);
}
