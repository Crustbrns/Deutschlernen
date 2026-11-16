import 'package:flutter/services.dart' show HapticFeedback;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Dark / light picker that behaves like an iOS segmented control: the
/// chosen segment sits on a raised thumb; tap a segment to move it, or drag
/// the thumb (it snaps to the nearer segment, a fast flick decides by
/// direction); the pressed thumb shrinks a little. Icons only: with labels
/// it squeezed the "Тема" title into one letter per line.
class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({super.key, required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch>
    with TickerProviderStateMixin {
  static const _height = 31.0; // = AppSwitch track: the right column lines up
  static const _pad = 2.0;
  static const _segmentWidth = 42.0;
  static const _flickVelocity = 300.0; // px/s

  /// Thumb position: 0 = dark (left), 1 = light (right).
  late final _position = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: _indexOf(widget.mode),
  );

  /// 0 = released, 1 = thumb pressed (shrunk).
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  var _dragging = false;

  static double _indexOf(ThemeMode mode) => mode == ThemeMode.light ? 1 : 0;

  @override
  void didUpdateWidget(ThemeSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Changed from outside, e.g. by tapping the row itself.
    if (widget.mode != oldWidget.mode && !_dragging) {
      _animateTo(_indexOf(widget.mode));
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _press.dispose();
    super.dispose();
  }

  void _animateTo(double target) =>
      _position.animateTo(target, curve: Curves.easeOutCubic);

  void _select(double index) {
    _animateTo(index);
    final mode = index == 1 ? ThemeMode.light : ThemeMode.dark;
    if (mode != widget.mode) {
      HapticFeedback.lightImpact();
      widget.onChanged(mode);
    }
  }

  /// Segment under a local x (0 = left, 1 = right).
  double _segmentAt(double dx) => dx < _pad + _segmentWidth ? 0 : 1;

  bool _onThumb(double dx) => _segmentAt(dx) == _position.value.round();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    const thumbRadius = (_height - 2 * _pad) / 2;

    Widget icon(IconData data, double index) {
      // Brighter the closer the thumb is, so it follows a drag too.
      final closeness = 1 - (_position.value - index).abs();
      return SizedBox(
        width: _segmentWidth,
        height: double.infinity,
        child: Icon(
          data,
          size: 18,
          color: Color.lerp(
            AppColors.quietText(colors),
            colors.onSurface,
            closeness,
          ),
        ),
      );
    }

    return Semantics(
      label:
          '${strings.theme}: '
          '${widget.mode == ThemeMode.light ? strings.themeLight : strings.themeDark}',
      button: true,
      onTap: () => _select(1 - _indexOf(widget.mode)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Press shrinks the thumb only when the finger is on it.
        onTapDown: (d) {
          if (_onThumb(d.localPosition.dx)) _press.forward();
        },
        onTapUp: (d) {
          _press.reverse();
          _select(_segmentAt(d.localPosition.dx));
        },
        onTapCancel: () {
          if (!_dragging) _press.reverse();
        },
        onHorizontalDragStart: (d) {
          _dragging = true;
          _position.stop();
          _press.forward();
        },
        onHorizontalDragUpdate: (d) {
          // The thumb travels one segment width; the controller clamps 0..1.
          _position.value += d.primaryDelta! / _segmentWidth;
        },
        onHorizontalDragEnd: (d) {
          final velocity = d.primaryVelocity ?? 0;
          final index = velocity.abs() > _flickVelocity
              ? (velocity > 0 ? 1.0 : 0.0)
              : _position.value.roundToDouble();
          _dragging = false;
          _press.reverse();
          _select(index);
        },
        onHorizontalDragCancel: () {
          _dragging = false;
          _press.reverse();
          _animateTo(_indexOf(widget.mode));
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_position, _press]),
          builder: (context, _) => Container(
            width: 2 * _segmentWidth + 2 * _pad,
            height: _height,
            padding: const EdgeInsets.all(_pad),
            decoration: BoxDecoration(
              // subtleButton, not card: the switch sits inside a card.
              color: palette.subtleButton,
              borderRadius: BorderRadius.circular(_height / 2),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: _position.value * _segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: _segmentWidth,
                  child: Transform.scale(
                    scale: 1 - 0.06 * _press.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.segmentThumb,
                        borderRadius: BorderRadius.circular(thumbRadius),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.switchThumbShadow,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Fill: a bare Row would sit in the top-left corner of the
                // Stack, only as tall as an icon.
                Positioned.fill(
                  child: Row(
                    children: [icon(AppIcons.moon, 0), icon(AppIcons.sun, 1)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
