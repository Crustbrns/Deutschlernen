import 'package:flutter/services.dart' show HapticFeedback;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// iOS-like on/off switch with an oval thumb (wider than tall), which
/// neither CupertinoSwitch nor Material's Switch can draw.
///
/// Like iOS: tap toggles; the thumb can be dragged and snaps to the nearer
/// side (a fast flick decides by direction); while pressed the thumb
/// stretches; the track color follows the thumb.
class AppSwitch extends StatefulWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> with TickerProviderStateMixin {
  static const _trackWidth = 60.0; // +4 with the thumb: keeps 17px of travel
  static const _trackHeight = 31.0;
  static const _thumbWidth = 37.0;
  static const _thumbHeight = 25.0;
  static const _stretch = 6.0; // extra thumb width while pressed
  static const _pad = (_trackHeight - _thumbHeight) / 2;
  static const _flickVelocity = 300.0; // px/s: faster = decide by direction

  /// Thumb position: 0 = off (left), 1 = on (right).
  late final _position = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: widget.value ? 1 : 0,
  );

  /// 0 = released, 1 = pressed (stretched thumb).
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  var _dragging = false;

  @override
  void didUpdateWidget(AppSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Changed from outside (row tap, or after our own onChanged).
    if (widget.value != oldWidget.value && !_dragging) _animateTo(widget.value);
  }

  @override
  void dispose() {
    _position.dispose();
    _press.dispose();
    super.dispose();
  }

  void _animateTo(bool on) =>
      _position.animateTo(on ? 1 : 0, curve: Curves.easeOutCubic);

  /// Distance the thumb travels at its normal width.
  double get _travel => _trackWidth - 2 * _pad - _thumbWidth;

  void _commit(bool on) {
    _animateTo(on);
    if (on != widget.value) {
      HapticFeedback.lightImpact();
      widget.onChanged(on);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final on = velocity.abs() > _flickVelocity
        ? velocity > 0
        : _position.value >= 0.5;
    _dragging = false;
    _press.reverse();
    _commit(on);
  }

  @override
  Widget build(BuildContext context) {
    final offColor = AppPalette.of(context).subtleButton;

    return Semantics(
      toggled: widget.value,
      onTap: () => _commit(!widget.value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) {
          _press.reverse();
          _commit(!widget.value);
        },
        onTapCancel: () {
          // A drag also cancels the tap; keep the thumb stretched then.
          if (!_dragging) _press.reverse();
        },
        onHorizontalDragStart: (_) {
          _dragging = true;
          _position.stop();
          _press.forward();
        },
        onHorizontalDragUpdate: (details) {
          // The controller clamps the value to 0..1.
          _position.value += details.primaryDelta! / _travel;
        },
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: () {
          _dragging = false;
          _press.reverse();
          _animateTo(widget.value);
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_position, _press]),
          builder: (context, _) {
            final t = _position.value;
            final thumbWidth = _thumbWidth + _stretch * _press.value;
            // The stretched thumb keeps its outer edge, grows toward the middle.
            final left = _pad + t * (_trackWidth - 2 * _pad - thumbWidth);

            return Container(
              width: _trackWidth,
              height: _trackHeight,
              decoration: BoxDecoration(
                color: Color.lerp(offColor, AppColors.softBlue, t),
                borderRadius: BorderRadius.circular(_trackHeight / 2),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: left,
                    top: _pad,
                    child: Container(
                      width: thumbWidth,
                      height: _thumbHeight,
                      decoration: BoxDecoration(
                        // White in both themes, like the iOS thumb.
                        color: AppColors.onAccent,
                        borderRadius: BorderRadius.circular(_thumbHeight / 2),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
