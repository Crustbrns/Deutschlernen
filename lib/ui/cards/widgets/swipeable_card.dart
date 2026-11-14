import 'package:material_ui/material_ui.dart';

enum SwipeDirection { left, right }

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
  late final AnimationController _controller = AnimationController(vsync: this);
  Animation<double>? _animation;
  double _drag = 0;
  bool _isSwiping = false;
  bool _enterHandled = false;

  // While an animation runs it drives the position, otherwise the finger does.
  double get _dx => _animation?.value ?? _drag;

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
      _drag = from == SwipeDirection.right ? width * 1.2 : -width * 1.2;
      _run(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        onDone: _resetPosition,
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

  void _resetPosition() {
    setState(() {
      _animation = null;
      _drag = 0;
    });
  }

  void _onDragStart(DragStartDetails details) {
    if (_isSwiping) return;
    _controller.stop();
    _drag = _dx;
    _animation = null;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isSwiping) return;
    setState(() => _drag += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isSwiping) return;

    final width = MediaQuery.sizeOf(context).width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final flung = velocity.abs() > 700;
    final draggedFarEnough = _drag.abs() > width * 0.25;

    if (flung || draggedFarEnough) {
      final goRight = flung ? velocity > 0 : _drag > 0;
      swipe(goRight ? SwipeDirection.right : SwipeDirection.left);
    } else {
      _run(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        onDone: _resetPosition,
      );
    }
  }

  /// Flies the card off screen. Used by drags and by the bottom buttons.
  void swipe(SwipeDirection direction) {
    if (_isSwiping || !widget.enabled) return;
    _isSwiping = true;
    widget.onSwipeStarted();

    final width = MediaQuery.sizeOf(context).width;
    _controller.stop();
    _drag = _dx;
    _animation = null;

    _run(
      direction == SwipeDirection.right ? width * 1.5 : -width * 1.5,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      onDone: () => widget.onSwiped(direction),
    );
  }

  void _run(
    double target, {
    required Duration duration,
    required Curve curve,
    required VoidCallback onDone,
  }) {
    _animation = Tween<double>(begin: _drag, end: target).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
    _controller.duration = duration;
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) onDone();
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
      child: AnimatedBuilder(
        animation: _controller,
        child: RepaintBoundary(child: widget.child),
        builder: (context, child) {
          final dx = _dx;
          return Transform.translate(
            offset: Offset(dx, 0),
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