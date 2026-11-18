part of 'progress_chart.dart';

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
    required this.barWidth,
    required this.minSegment,
    required this.scale,
    required this.segmentColors,
    required this.labels,
    required this.labelStyle,
    required this.gridColor,
  });

  final List<ChartBar> bars;
  final double slot;
  final double barWidth;
  final double minSegment; // see ProgressChart.segmentHeight
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
    // Segment edges of each bar: [(bottom, top)] per status, in pixels.
    List<(double, double)>? edges(ChartBar bar) {
      final layers = bar.layers;
      if (layers == null || layers.every((v) => v == 0)) return null;
      var y = ProgressChart._plotHeight;
      return [
        for (final v in layers)
          (y, y -= ProgressChart.segmentHeight(v, scale, minSegment)),
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
      // Tighter lines: day and month read as one label.
      text: TextSpan(text: text, style: labelStyle.copyWith(height: 1.05)),
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
        var isLowest = true;
        for (var s = 0; s < e.length; s++) {
          var (bottom, segTop) = _inset(e[s]);
          if (bottom <= segTop) continue; // empty status
          // The lowest segment stands on the axis: no gap, square bottom.
          if (isLowest) bottom = e[s].$1;
          canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              left,
              segTop,
              left + barWidth,
              bottom,
              topLeft: _radius,
              topRight: _radius,
              bottomLeft: isLowest ? Radius.zero : _radius,
              bottomRight: isLowest ? Radius.zero : _radius,
            ),
            Paint()..color = segmentColors[s],
          );
          isLowest = false;
          _paintCount(
            canvas,
            bars[i].layers![s],
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
              ProgressChart._labelGap +
              (ProgressChart._labelHeight -
                      ProgressChart._labelGap -
                      tp.height) /
                  2,
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
      old.barWidth != barWidth ||
      old.minSegment != minSegment ||
      old.scale != scale ||
      !listEquals(old.labels, labels) ||
      old.labelStyle != labelStyle ||
      old.gridColor != gridColor ||
      !listEquals(old.segmentColors, segmentColors);
}
