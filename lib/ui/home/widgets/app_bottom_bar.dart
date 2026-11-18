import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/services.dart' show HapticFeedback;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/home/widgets/bar_tab.dart';
import 'package:deutschlernen/ui/home/widgets/glass_lens.dart';

/// Order of the tabs in the bottom bar and in the shell's page stack.
enum HomeTab { learn, categories, progress, settings }

/// Floating bottom navigation: a frosted-glass pill inset from the screen
/// edges; the content scrolls under it (Scaffold.extendBody) and shows
/// through blurred.
///
/// The selected tab sits on a lighter pill. On a tap or a drag along the bar
/// the pill "lifts" into a glass lens (iOS 26 style): it grows a little,
/// magnifies and refracts the tabs under it, slides, and settles back.
/// Dragging moves the lens with the finger; release selects the nearest tab.
class AppBottomBar extends StatefulWidget {
  const AppBottomBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar>
    with TickerProviderStateMixin {
  static const _radius = 34.0;
  static const _inset = 6.0; // gap between the bar's edge and the pill
  static const _tabHeight = 58.0;

  /// Slide between tabs. Positions are in tab units (0 = first tab),
  /// so they don't depend on the bar's width.
  late final _move = AnimationController(
    vsync: this,
    duration: _slide,
    value: 1,
  );
  static const _slide = Duration(milliseconds: 420);

  /// Reduce Motion: a short slide and no lens.
  static const _calmSlide = Duration(milliseconds: 150);
  bool _reduceMotion = false;

  /// Lens held up by a finger dragging along the bar.
  late final _hold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    reverseDuration: const Duration(milliseconds: 240),
  );

  late double _fromPos = widget.selected.index.toDouble();
  late double _toPos = _fromPos;
  bool _dragging = false;

  /// The current slide came from a tap: the lens rises and falls with it.
  bool _bump = false;
  int _lastDragTab = 0; // for one haptic tick per tab crossed

  @override
  void didUpdateWidget(AppBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tab changed from outside the bar: slide there without the lens.
    final index = widget.selected.index;
    if (!_dragging && index != _toPos.round()) {
      _slideTo(index.toDouble(), bump: false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _move.dispose();
    _hold.dispose();
    super.dispose();
  }

  // Slow start, fast middle, slow end. Quart is stronger than Cubic:
  // the soft ends are clearly visible.
  double get _pos => lerpDouble(
    _fromPos,
    _toPos,
    Curves.easeInOutQuart.transform(_move.value),
  )!;

  /// 0 = flat pill, 1 = lens fully up.
  /// A tap is one continuous arc over the slide: it rises and falls in the
  /// same motion, with no hand-off between animations. sin² instead of sin:
  /// plain sin is fastest at the very start and end (a jump up, a drop
  /// down); sin² starts and ends at zero speed.
  double get _lift {
    if (_reduceMotion) return 0;
    final bump = _bump
        ? math.pow(math.sin(math.pi * _move.value), 2).toDouble()
        : 0.0;
    final hold = Curves.easeInOut.transform(_hold.value);
    return math.max(bump, hold);
  }

  void _slideTo(double target, {required bool bump}) {
    _fromPos = _pos;
    _toPos = target;
    _bump = bump;
    _move.duration = _reduceMotion ? _calmSlide : _slide;
    _move.forward(from: 0);
  }

  void _select(int index) {
    if (index != widget.selected.index) HapticFeedback.selectionClick();
    // Slide first: _toPos then already matches, so didUpdateWidget
    // doesn't start a second slide.
    _slideTo(index.toDouble(), bump: true);
    widget.onSelected(HomeTab.values[index]);
  }

  /// Finger x → tab position, the lens centered under the finger.
  double _posAt(double dx, double tabWidth) =>
      (dx / tabWidth - 0.5).clamp(0.0, HomeTab.values.length - 1.0);

  void _onDragStart(double dx, double tabWidth) {
    _dragging = true;
    _move.stop();
    _bump = false;
    _fromPos = _toPos = _posAt(dx, tabWidth);
    _move.value = 1;
    _lastDragTab = _toPos.round();
    _hold.forward();
  }

  void _onDragUpdate(double dx, double tabWidth) {
    setState(() => _fromPos = _toPos = _posAt(dx, tabWidth));
    final tab = _toPos.round();
    if (tab != _lastDragTab) {
      _lastDragTab = tab;
      HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd() {
    _dragging = false;
    final index = _pos.round();
    // Snap to the nearest tab while the lens settles, at the same time.
    _slideTo(index.toDouble(), bump: false);
    _hold.reverse();
    if (index != widget.selected.index) {
      widget.onSelected(HomeTab.values[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);
    final colors = Theme.of(context).colorScheme;

    // Solid (Fill) icons, the user's choice.
    final tabs = [
      (AppIcons.houseFill, strings.tabLearn),
      // Categories: the word levels and the search.
      (AppIcons.squaresFourFill, strings.tabCategories),
      (AppIcons.fileTextFill, strings.tabProgress),
      (AppIcons.gearFill, strings.tabSettings),
    ];

    // Floats above the home indicator; on phones without one, a fixed gap.
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom : 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 2 * _inset) / tabs.length;
          // Drag coordinates are relative to the whole bar; tabs start
          // after the inset.
          double inner(double dx) => dx - _inset;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _select(
              (inner(d.localPosition.dx) / tabWidth).floor().clamp(
                0,
                tabs.length - 1,
              ),
            ),
            onHorizontalDragStart: (d) =>
                _onDragStart(inner(d.localPosition.dx), tabWidth),
            onHorizontalDragUpdate: (d) =>
                _onDragUpdate(inner(d.localPosition.dx), tabWidth),
            onHorizontalDragEnd: (_) => _onDragEnd(),
            onHorizontalDragCancel: _onDragEnd,
            child: AnimatedBuilder(
              animation: Listenable.merge([_move, _hold]),
              builder: (context, _) {
                final lift = _lift;
                final pillLeft = _pos * tabWidth;

                return Stack(
                  // The lens grows past the bar's edges.
                  clipBehavior: Clip.none,
                  children: [
                    _buildBar(palette, colors, tabs, tabWidth, pillLeft, lift),
                    if (lift > 0.01) _buildLens(tabWidth, pillLeft, lift),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBar(
    AppPalette palette,
    ColorScheme colors,
    List<(IconData, String)> tabs,
    double tabWidth,
    double pillLeft,
    double lift,
  ) {
    // ClipRRect: the blur stays inside the pill, not the whole screen.
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Semi-transparent: labels stay readable over any content.
            color: palette.card.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(_radius),
            // Thin edge, so the pill separates from content of the same color.
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_inset),
            child: SizedBox(
              height: _tabHeight,
              child: Stack(
                children: [
                  // Flat pill under the selected tab; fades out while the
                  // lens is up, so there is only one highlight.
                  Positioned(
                    left: pillLeft,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Opacity(
                      opacity: 1 - lift,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          // onSurface-based: lighter in dark, darker in light.
                          color: colors.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(_radius - _inset),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        Expanded(
                          child: BarTab(
                            icon: tabs[i].$1,
                            label: tabs[i].$2,
                            isSelected: i == widget.selected.index,
                            onTap: () => _select(i),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The lifted lens, centered on the flat pill and a bit bigger.
  Widget _buildLens(double tabWidth, double pillLeft, double lift) {
    final width = tabWidth * (1 + 0.2 * lift);
    final height = _tabHeight * (1 + 0.22 * lift);
    // Center of the flat pill, in the outer Stack's coordinates.
    final cx = _inset + pillLeft + tabWidth / 2;
    const cy = _inset + _tabHeight / 2;

    return Positioned(
      left: cx - width / 2,
      top: cy - height / 2,
      width: width,
      height: height,
      child: GlassLens(size: Size(width, height), lift: lift),
    );
  }
}
