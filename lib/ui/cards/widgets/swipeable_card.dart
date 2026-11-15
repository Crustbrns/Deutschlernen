import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

enum SwipeDirection { left, right }

/*Tuning

Springier or calmer snap-back: stiffness and ratio in _snapBackSpring. Lower ratio means more bounce.
Flight speed limits: the 560 and 1120 ms values in swipe.
Tilt: 0.3. Button swipe arc: _buttonArc.
Highlight strength: _highlightDistance (fraction of the screen width that fully lights a button).*/

/// Lets other widgets (the bottom buttons) swipe the top card programmatically,
/// and tells them how far the card is being dragged.
class SwipeController {
  SwipeableCardState? _state;

  /// How far the top card is dragged sideways, from -1 (fully towards "known")
  /// to 1 (fully towards "learn"). 0 when the card is at rest.
  final ValueNotifier<double> dragProgress = ValueNotifier<double>(0);

  /// How far the top card has moved away, 0 (in place) to 1 (a full screen
  /// width or more), while dragged and while flying off. The card below
  /// grows with it, so it is already full size when the top one is gone.
  final ValueNotifier<double> reveal = ValueNotifier<double>(0);

  void swipe(SwipeDirection direction) => _state?.swipe(direction);

  void dispose() {
    dragProgress.dispose();
    reveal.dispose();
  }
}

class SwipeableCard extends StatefulWidget {
  const SwipeableCard({
    super.key,
    required this.child,
    required this.enabled,
    required this.controller,
    required this.onSwipeStarted,
    required this.onSwiped,
    this.enterFrom,
  });

  final Widget child;

  /// Only the top card of the stack is enabled.
  final bool enabled;
  final SwipeController controller;
  final VoidCallback onSwipeStarted;
  final ValueChanged<SwipeDirection> onSwiped;

  /// If set, the card flies in from this side when it first appears (undo).
  final SwipeDirection? enterFrom;

  @override
  State<SwipeableCard> createState() => SwipeableCardState();
}

class SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  /// Where the card is, in logical pixels. Dragging just sets the value,
  /// so no setState is needed.
  final ValueNotifier<Offset> _offset = ValueNotifier<Offset>(Offset.zero);

  /// Runs an animation from [_from] to [_to] as a 0..1 progress value.
  /// Unbounded, so the snap-back spring may overshoot.
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
  )..addListener(_onAnimationTick);

  Offset _from = Offset.zero;
  Offset _to = Offset.zero;

  static final _snapBackSpring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 320,
    ratio: 0.7, // slight overshoot, feels springy
  );

  /// Direction the button swipes fly in: slightly upward.
  static const _buttonArc = -0.08;

  /// Horizontal drag (fraction of the width) that fully lights a button.
  static const _highlightDistance = 0.3;

  bool _isSwiping = false;
  bool _enterHandled = false;

  /// True while the card flies in after an undo. The buttons stay unlit then.
  bool _isEntering = false;

  @override
  void initState() {
    super.initState();
    _offset.addListener(_publishProgress);
    _attachIfEnabled();
  }

  @override
  void didUpdateWidget(SwipeableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attachIfEnabled();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final from = widget.enterFrom;
    if (!_enterHandled && from != null && widget.enabled) {
      _enterHandled = true;
      _isEntering = true;
      final width = MediaQuery.sizeOf(context).width;
      _offset.value = Offset(
        from == SwipeDirection.right ? width * 1.2 : -width * 1.2,
        0,
      );
      _animateTo(
        Offset.zero,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      ).whenComplete(() => _isEntering = false);
    }
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _controller.dispose();
    _offset.dispose();
    super.dispose();
  }

  void _attachIfEnabled() {
    if (widget.enabled) widget.controller._state = this;
  }

  void _onAnimationTick() {
    _offset.value = Offset.lerp(_from, _to, _controller.value)!;
  }

  void _publishProgress() {
    if (!widget.enabled || _isEntering) return;
    final width = MediaQuery.sizeOf(context).width;
    widget.controller.reveal.value = (_offset.value.dx.abs() / width)
        .clamp(0.0, 1.0)
        .toDouble();
    widget.controller.dragProgress.value =
        (_offset.value.dx / (width * _highlightDistance))
            .clamp(-1.0, 1.0)
            .toDouble();
  }

  TickerFuture _animateTo(
    Offset target, {
    required Duration duration,
    required Curve curve,
  }) {
    _from = _offset.value;
    _to = target;
    _controller.value = 0;
    return _controller.animateTo(1, duration: duration, curve: curve);
  }

  void _onDragStart(DragStartDetails details) {
    if (_isSwiping) return;
    _controller.stop(); // grab the card even while it is still springing back
    _isEntering = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isSwiping) return;
    _offset.value += details.delta;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isSwiping) return;

    final width = MediaQuery.sizeOf(context).width;
    final velocity = details.velocity.pixelsPerSecond;
    final offset = _offset.value;

    // The decision depends on the horizontal part only, so a diagonal
    // swipe counts as left or right.
    final flung = velocity.dx.abs() > 700;
    final draggedFarEnough = offset.dx.abs() > width * 0.25;

    if (flung || draggedFarEnough) {
      final heading = flung ? velocity : offset;
      swipe(
        heading.dx > 0 ? SwipeDirection.right : SwipeDirection.left,
        heading: heading,
        speed: velocity.distance,
      );
    } else {
      _snapBack(velocity);
    }
  }

  void _snapBack(Offset velocity) {
    final from = _offset.value;
    final distanceSquared = from.dx * from.dx + from.dy * from.dy;
    if (distanceSquared < 0.01) return;

    _from = from;
    _to = Offset.zero;
    _controller.value = 0;

    // Progress runs 0 -> 1 while the card moves from -> zero, so the
    // release velocity is projected onto that line.
    final progressVelocity =
        -(velocity.dx * from.dx + velocity.dy * from.dy) / distanceSquared;
    _controller.animateWith(
      SpringSimulation(_snapBackSpring, 0, 1, progressVelocity),
    );
  }

  /// Flies the card off screen. Used by drags and by the bottom buttons.
  ///
  /// [heading] is the direction of flight; the card leaves along it until it
  /// is past the screen edge. Buttons pass none and get a slight upward arc.
  void swipe(SwipeDirection direction, {Offset? heading, double speed = 0}) {
    if (_isSwiping || !widget.enabled) return;
    _isSwiping = true;
    widget.onSwipeStarted();

    final width = MediaQuery.sizeOf(context).width;
    final sign = direction == SwipeDirection.right ? 1.0 : -1.0;
    final exitX = width * 1.3;

    var dir = heading ?? Offset(sign, _buttonArc);
    if (dir.dx.abs() < 1e-3) dir = Offset(sign, dir.dy);

    final scale = exitX / dir.dx.abs();
    final target = Offset(
      sign * exitX,
      (dir.dy * scale).clamp(-width * 2, width * 2).toDouble(),
    );
    final distance = (target - _offset.value).distance;

    // The faster the flick, the shorter the flight. Slow overall
    // (560–1120 ms) so the card visibly glides away; the next one then
    // appears quickly.
    final flightSpeed = speed.clamp(900, 4000);
    final ms = (distance / flightSpeed * 1000 * 2).clamp(560, 1120);

    _animateTo(
      target,
      duration: Duration(milliseconds: ms.round()),
      // Button: starts gently and speeds up — a smooth glide from rest.
      // Drag: the card is already moving, so it just keeps going and eases.
      curve: heading == null ? Curves.easeInOutCubic : Curves.easeOutCubic,
    ).whenComplete(() {
      if (!mounted) return;
      widget.controller.dragProgress.value = 0;
      widget.controller.reveal.value = 0; // the next card starts small again
      widget.onSwiped(direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Pan instead of horizontal drag, so the card follows the finger in
    // every direction. A scrollable child still wins vertical drags.
    return GestureDetector(
      onPanStart: widget.enabled ? _onDragStart : null,
      onPanUpdate: widget.enabled ? _onDragUpdate : null,
      onPanEnd: widget.enabled ? _onDragEnd : null,
      onPanCancel: widget.enabled && !_isSwiping
          ? () => _snapBack(Offset.zero)
          : null,
      child: ValueListenableBuilder<Offset>(
        valueListenable: _offset,
        // Painted once, then only moved around while swiping.
        child: RepaintBoundary(child: widget.child),
        builder: (context, offset, child) {
          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: (offset.dx / width) * 0.3,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
