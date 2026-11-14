import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

enum SwipeDirection { left, right }

/*Tuning

Springier or calmer snap-back: stiffness and ratio in _snapBackSpring. Lower ratio means more bounce.
Flight speed limits: the 140 and 320 ms values in swipe.
Tilt: 0.3. Arc: 0.06.*/

/// Lets other widgets (the bottom buttons) swipe the top card programmatically.
class SwipeController {
  SwipeableCardState? _state;

  void swipe(SwipeDirection direction) => _state?.swipe(direction);
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
  // The controller's value IS the horizontal offset in logical pixels.
  // Dragging just sets the value, so no setState is needed.
  late final AnimationController _controller =
      AnimationController.unbounded(vsync: this);

  static final _snapBackSpring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 320,
    ratio: 0.7, // slight overshoot, feels springy
  );

  bool _isSwiping = false;
  bool _enterHandled = false;

  @override
  void initState() {
    super.initState();
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
      final width = MediaQuery.sizeOf(context).width;
      _controller.value = from == SwipeDirection.right ? width * 1.2 : -width * 1.2;
      _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _controller.dispose();
    super.dispose();
  }

  void _attachIfEnabled() {
    if (widget.enabled) widget.controller._state = this;
  }

  void _onDragStart(DragStartDetails details) {
    if (_isSwiping) return;
    _controller.stop(); // grab the card even while it is still springing back
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isSwiping) return;
    _controller.value += details.delta.dx;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isSwiping) return;

    final width = MediaQuery.sizeOf(context).width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final dx = _controller.value;

    final flung = velocity.abs() > 700;
    final draggedFarEnough = dx.abs() > width * 0.25;

    if (flung || draggedFarEnough) {
      final goRight = flung ? velocity > 0 : dx > 0;
      swipe(
        goRight ? SwipeDirection.right : SwipeDirection.left,
        velocity: velocity,
      );
    } else {
      _snapBack(velocity);
    }
  }

  void _snapBack(double velocity) {
    _controller.animateWith(
      SpringSimulation(_snapBackSpring, _controller.value, 0, velocity),
    );
  }

  /// Flies the card off screen. Used by drags and by the bottom buttons.
  void swipe(SwipeDirection direction, {double velocity = 0}) {
    if (_isSwiping || !widget.enabled) return;
    _isSwiping = true;
    widget.onSwipeStarted();

    final width = MediaQuery.sizeOf(context).width;
    final target = direction == SwipeDirection.right ? width * 1.3 : -width * 1.3;
    final distance = (target - _controller.value).abs();

    // The faster the flick, the shorter the flight.
    final speed = velocity.abs().clamp(900, 4000);
    final ms = (distance / speed * 1000).clamp(140, 320);

    _controller
        .animateTo(
          target,
          duration: Duration(milliseconds: ms.round()),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
      if (mounted) widget.onSwiped(direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Horizontal drags only, so the vertical scroll inside the card still works.
    return GestureDetector(
      onHorizontalDragStart: widget.enabled ? _onDragStart : null,
      onHorizontalDragUpdate: widget.enabled ? _onDragUpdate : null,
      onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
      onHorizontalDragCancel: widget.enabled && !_isSwiping
          ? () => _snapBack(0)
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        // Painted once, then only moved around while swiping.
        child: RepaintBoundary(child: widget.child),
        builder: (context, child) {
          final dx = _controller.value;
          return Transform.translate(
            offset: Offset(dx, -dx.abs() * 0.06), // slight upward arc
            child: Transform.rotate(
              angle: (dx / width) * 0.3,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
      ),
    );
  }
}