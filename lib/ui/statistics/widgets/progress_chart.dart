import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/statistics/view_models/progress_chart_data.dart';

/// Stacked bars (known, learning, review, learned from the bottom) joined by
/// translucent bands, so the eye follows each status from bar to bar.
/// Scrolls sideways when the bars don't fit; starts at the latest one.
class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key, required this.bars});

  final List<ChartBar> bars;

  /// Bottom to top; the same colors as the status strips in the word lists.
  static const stackOrder = [
    WordStatus.known,
    WordStatus.learning,
    WordStatus.review,
    WordStatus.learned,
  ];

  static const _plotHeight = 220.0;
  static const _labelHeight = 26.0; // x labels under the bars
  static const _axisWidth = 34.0; // y labels
  static const _minSlot = 52.0; // narrower slots scroll instead

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final ticks = _ticks(
      bars.fold(0, (m, b) => math.max(m, b.counts?.total ?? 0)),
    );
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: palette.mutedText,
    );

    return SizedBox(
      height: _plotHeight + _labelHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _axisWidth,
            child: CustomPaint(
              painter: _AxisPainter(ticks: ticks, style: labelStyle),
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
                    top: ticks.last,
                    segmentColors: [
                      for (final s in stackOrder)
                        AppColors.forWordStatus(s, colors),
                    ],
                    labelStyle: labelStyle,
                  ),
                );
                return Stack(
                  children: [
                    // Grid stays put while the bars scroll over it.
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPainter(
                          ticks: ticks,
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

  /// 0 and 4 evenly spaced round values covering [max]: steps of 1, 2, 5,
  /// 10, 20, 50, …
  static List<int> _ticks(int max) {
    const count = 4;
    var step = 1;
    for (var base = 1; ; base *= 10) {
      final s = [1, 2, 5]
          .map((m) => m * base)
          .firstWhere((s) => s * count >= max, orElse: () => 0);
      if (s > 0) {
        step = s;
        break;
      }
    }
    return [for (var i = 0; i <= count; i++) i * step];
  }

  static double _y(int value, int top) =>
      _plotHeight - value / top * (_plotHeight - 8);
}

/// Y labels, centered on their grid lines.
class _AxisPainter extends CustomPainter {
  _AxisPainter({required this.ticks, required this.style});

  final List<int> ticks;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    for (final t in ticks) {
      final tp = TextPainter(
        text: TextSpan(text: '$t', style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = ProgressChart._y(t, ticks.last);
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_AxisPainter old) =>
      old.ticks.last != ticks.last || old.style != style;
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.ticks, required this.color});

  final List<int> ticks;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (final t in ticks) {
      final y = ProgressChart._y(t, ticks.last);
      // Dashed: quieter than solid lines behind the bars.
      for (var x = 0.0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.ticks.last != ticks.last || old.color != color;
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.bars,
    required this.slot,
    required this.top,
    required this.segmentColors,
    required this.labelStyle,
  });

  final List<ChartBar> bars;
  final double slot;
  final int top; // value at the top grid line
  final List<Color> segmentColors;
  final TextStyle labelStyle;

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
      var sum = 0;
      return [
        for (final v in counts.stack)
          (ProgressChart._y(sum, top), ProgressChart._y(sum += v, top)),
      ];
    }

    final all = [for (final b in bars) edges(b)];

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
            segmentColors[s],
          );
        }
      }

      final d = bars[i].start;
      final tp = TextPainter(
        text: TextSpan(text: '${d.day}.${d.month}', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
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

  /// The word count in the middle of a segment: black, or white on the
  /// black "known" segment of the light theme. Skipped when it doesn't fit.
  void _paintCount(Canvas canvas, int value, Rect rect, Color fill) {
    final light =
        ThemeData.estimateBrightnessForColor(fill) == Brightness.light;
    final tp = TextPainter(
      text: TextSpan(
        text: '$value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: light ? AppColors.chartCountDark : AppColors.chartCountLight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (tp.height + 2 > rect.height || tp.width + 4 > rect.width) return;
    tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
  }

  // Leaves a thin gap between stacked segments.
  static (double, double) _inset((double, double) e) =>
      (e.$1 - _gap / 2, e.$2 + _gap / 2);

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.bars != bars ||
      old.slot != slot ||
      old.top != top ||
      old.labelStyle != labelStyle ||
      !listEquals(old.segmentColors, segmentColors);
}
